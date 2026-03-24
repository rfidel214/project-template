/**
 * OpenCode Context Monitor Plugin
 *
 * Mirrors the Claude Code context monitor cron for OpenCode sessions.
 * Reminds the agent to capture to OpenBrain before context compaction.
 *
 * Events used:
 *   session.idle       — fires after inactivity; prompt agent to check and capture
 *   session.compacted  — fires after compaction; prompt agent to capture remaining state
 */

export default async function contextMonitorPlugin(hooks) {

  // Fires when the session goes idle (agent not actively working)
  // Use this as a soft prompt to capture recent progress
  hooks.on("session.idle", async () => {
    return {
      inject: [
        {
          role: "system",
          content:
            "CONTEXT MONITOR (idle check): If you have completed any significant work " +
            "since your last OpenBrain capture — fixed an error, closed a bead, made a decision, " +
            "discovered something non-obvious — capture it NOW using capture_thought() before " +
            "continuing. Use [TASK <id>] [CATEGORY] format. Do not defer. " +
            "If nothing new since last capture, continue normally.",
        },
      ],
    };
  });

  // Fires immediately after context compaction occurs
  // Use this to capture any state that survived compaction
  hooks.on("session.compacted", async () => {
    return {
      inject: [
        {
          role: "system",
          content:
            "CONTEXT COMPACTED: Context was just compacted. Run /session-capture-checklist " +
            "immediately. Capture all errors, discoveries, decisions, and progress from this " +
            "session that may not have been captured yet. Update beads notes. " +
            "Do not continue working until captures are complete.",
        },
      ],
    };
  });

}
