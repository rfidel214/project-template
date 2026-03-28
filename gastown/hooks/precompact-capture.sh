#!/bin/bash
# PreCompact hook for Mayor — forces OpenBrain capture before context loss
# This script is called by Claude Code before compacting context.
# It outputs a prompt that gets injected into the conversation.

cat << 'PROMPT'
Context is about to be compacted. Before it's lost, capture the most important uncaptured findings from this session to OpenBrain using capture_thought. For each capture, tag with [TASK {id}] where {id} is the beads task ID from bd prime output. Focus on:
1. Any errors encountered and their fixes
2. Any discoveries about how systems work
3. Current state of work and what's next
4. Any decisions made and their rationale

Be concise — 2-4 captures max. This is a safety net, not a full session summary.
Use the format: [TASK {id}] [CATEGORY] description
Categories: ERROR, DISCOVERY, BLOCKER, DECISION, HANDOFF, PROGRESS
PROMPT
