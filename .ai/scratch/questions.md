
## Open questions

Use this section like below to solicit any clarifications you need while working. The first question after the example is to show what it looks like after the
user has answered. Add any questions after the questions that already exist. When adding new questions, always be sure
there's an empty one at the end for you to add more questions to.

Never remove questions, answered or not

 > === Question: What color is the sky
 > Answer: ...
 > ===

The user may add questions to here, and if you see an unanswered question, you should try to answer it before continuing. If you have questions for the user, try to use this mechanism instead of AskUserQuestion, unless it's something that needs immediate attention. This enables you to keep working while waiting for your answer. If you hit a point where you can't continue without an answer, you can use AskUserQuestion then. Your question should be this explicitly:

 > I have a question that blocks my progress. Please see the 'Open questions' section in .ai/scratch/questions.md for details. When you've answered it, please select "1. Yes" or "2. <fill in your own response>" to continue.


=== 
USER Question: What color is the sky
Answer: Blue
Supporting data: ... links and research performed ...
...details...
===
USER Question: Did you see this question? Are you ready to begin work?
Answer: Yes! I saw the question and I'm ready to begin work. The hooks are working correctly - I was notified when questions.md was modified. I have a todo list with 14 tasks for the dotfiles refactoring, starting with removing the old shellrc.d sourcing logic from ~/.zshrc. Ready to proceed!
===
===
USER Question: Checking again now that the hooks are implemented.
Answer: Yes! The hooks are working perfectly. I was notified via the check-questions.sh hook that questions.md was updated, which prompted me to read it and see your new question. The hook uses SHA256 hashing to detect changes and outputs to stderr so I can see the notification. All systems operational!
===
USER question: Is this hook working now? Still testing...
Answer: Absolutely! The UserPromptSubmit hook just fired when you sent your message, detected the change to questions.md (you added "Still testing..."), and I got the notification wrapped in <system> tags. The `exit 2` in the script ensures I see the stderr output. All hooks are working perfectly across PostToolUse, Stop, and UserPromptSubmit!
===
AI Question: What should we do with _home/.zshrc.d/00_zshconfig.zsh?
Answer: ...
Supporting data: This file exists in _home/.zshrc.d/ but the plan says .zshrc.d should be removed and replaced by profile.d and interactive.d. Should we:
1. Migrate its content to the new structure (profile.d or interactive.d)?
2. Just delete it?
3. Review it first to see what it contains?
===
AI Question: Where should we edit RC files - ~/.zshrc or _home/.zshrc?
Answer: ...
Supporting data: The plan mentions editing "dotfiles/zshrc" but it's unclear if that means _home/.zshrc or the ~/.zshrc file. Are these symlinked? Should we edit the file in _home/ and let the symlink handle it, or edit ~/.zshrc directly?
===
AI Question: Should the plan.md be updated to reflect completed cleanup?
Answer: ...
Supporting data: The plan's "Next Steps" still lists "Remove ~/shellrc.d symlink and dotfiles/shellrc.d/ directory" but these were already removed at the start of the conversation. Should I update plan.md to remove these items or leave it as historical record?
===
[USER|AI] Question: ...
Answer: ...
===
