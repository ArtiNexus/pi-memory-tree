#!/usr/bin/env python3
"""
raw_search.sh — Search raw JSONL session transcripts for relevant messages.
Falls back when memory tree and session summaries are insufficient.
Searches BOTH user and assistant messages by default (best recall).

Usage:
  raw_search.sh "<keyword>"              # Search all raw logs (user + assistant)
  raw_search.sh "<keyword>" --last 3     # Last N files only
  raw_search.sh "<keyword>" --user-only  # Only user messages
  raw_search.sh "<keyword>" --context    # Show surrounding context
  raw_search.sh --count                  # Stats
  raw_search.sh --help
"""

import json
import os
import sys
import glob
from datetime import datetime

SESSIONS_DIR = os.path.expanduser("~/.pi/agent/sessions")

def get_all_jsonl_files():
    files = []
    for root, dirs, fnames in os.walk(SESSIONS_DIR):
        for f in fnames:
            if f.endswith('.jsonl'):
                files.append(os.path.join(root, f))
    files.sort(key=os.path.getmtime, reverse=True)
    return files

def extract_user_text(msg):
    """Extract text content from a user message."""
    texts = []
    for c in msg.get('content', []):
        if c.get('type') == 'text':
            texts.append(c['text'])
    return '\n'.join(texts)

def extract_assistant_text(msg):
    """Extract text content from an assistant message."""
    texts = []
    for c in msg.get('content', []):
        if c.get('type') == 'text':
            texts.append(c['text'])
    return '\n'.join(texts)

def search_file(filepath, keyword, user_only=False, show_context=False):
    """Search a single JSONL file for the keyword.
    
    By default searches both user and assistant messages for best recall.
    """
    results = []
    messages = []
    
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
                if d.get('type') == 'message':
                    messages.append(d)
            except json.JSONDecodeError:
                continue
    
    for i, msg in enumerate(messages):
        msg_data = msg.get('message', {})
        role = msg_data.get('role', '')
        
        if user_only and role != 'user':
            continue
        if role not in ('user', 'assistant'):
            continue
        
        text = extract_user_text(msg_data) if role == 'user' else extract_assistant_text(msg_data)
        
        if keyword.lower() in text.lower():
            timestamp = msg.get('timestamp', '')
            result = {
                'file': os.path.basename(filepath),
                'timestamp': timestamp,
                'role': role,
                'preview': text[:400],
            }
            
            if show_context:
                # Show context: 1 message before and after
                if i > 0:
                    prev = messages[i-1].get('message', {})
                    prev_role = prev.get('role', '')
                    prev_text = extract_user_text(prev) if prev_role == 'user' else extract_assistant_text(prev)
                    result['context_before'] = f"[{prev_role}] {prev_text[:200]}"
                if i + 1 < len(messages):
                    nxt = messages[i+1].get('message', {})
                    nxt_role = nxt.get('role', '')
                    nxt_text = extract_user_text(nxt) if nxt_role == 'user' else extract_assistant_text(nxt)
                    result['context_after'] = f"[{nxt_role}] {nxt_text[:200]}"
            
            results.append(result)
    
    return results

def count_stats():
    """Count files and messages."""
    files = get_all_jsonl_files()
    total_msgs = 0
    total_user = 0
    total_size = 0
    
    for fp in files:
        total_size += os.path.getsize(fp)
        with open(fp, 'r', encoding='utf-8', errors='replace') as f:
            for line in f:
                if '"type":"message"' in line:
                    total_msgs += 1
                    if '"role":"user"' in line:
                        total_user += 1
    
    return {
        'files': len(files),
        'total_size_bytes': total_size,
        'total_messages': total_msgs,
        'user_messages': total_user
    }

def main():
    if '--help' in sys.argv or len(sys.argv) < 2:
        print("Usage:")
        print("  raw_search.sh \"<keyword>\"                  # Search all raw logs")
        print("  raw_search.sh \"<keyword>\" --last N         # Last N files")
        print("  raw_search.sh \"<keyword>\" --context        # Show assistant response too")
        print("  raw_search.sh --count                       # Show stats")
        return
    
    if '--count' in sys.argv:
        stats = count_stats()
        print(f"📊 Raw Log Stats:")
        print(f"   Files:        {stats['files']}")
        print(f"   Total size:   {stats['total_size_bytes']/1024/1024:.1f} MB")
        print(f"   Messages:     {stats['total_messages']}")
        print(f"   User msgs:    {stats['user_messages']}")
        return
    
    # Extract keyword (first non-flag argument)
    keyword = None
    last_n = None
    user_only = '--user-only' in sys.argv
    show_context = '--context' in sys.argv
    
    for arg in sys.argv[1:]:
        if arg.startswith('--'):
            if arg.startswith('--last'):
                idx = sys.argv.index(arg)
                if idx + 1 < len(sys.argv):
                    try:
                        last_n = int(sys.argv[idx + 1])
                    except ValueError:
                        pass
            continue
        if keyword is None:
            keyword = arg
    
    if not keyword:
        print("❌ Please provide a keyword")
        sys.exit(1)
    
    files = get_all_jsonl_files()
    
    if last_n:
        files = files[:last_n]
    
    all_results = []
    for fp in files:
        try:
            results = search_file(fp, keyword, user_only, show_context)
            all_results.extend(results)
        except Exception as e:
            print(f"⚠️  Error reading {os.path.basename(fp)}: {e}", file=sys.stderr)
    
    if not all_results:
        print(f"🔍 No matches for '{keyword}' in raw session logs")
        sys.exit(0)
    
    print(f"🔍 Raw log search: '{keyword}' → {len(all_results)} matches\n")
    
    for i, r in enumerate(all_results, 1):
        role_icon = '💬' if r['role'] == 'user' else '🤖'
        print(f"[{i}] {role_icon} {r['role']}  |  📄 {r['file']}")
        print(f"    🕐 {r['timestamp']}")
        print(f"    {r['preview'][:250]}{'...' if len(r['preview']) > 250 else ''}")
        if show_context:
            if 'context_before' in r:
                print(f"    ⬆️  {r['context_before']}")
            if 'context_after' in r:
                print(f"    ⬇️  {r['context_after']}")
        print()

if __name__ == '__main__':
    main()
