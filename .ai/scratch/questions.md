
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


=== USER Question: What color is the sky
Answer: Blue
Supporting data: ... links and research performed ...
...details...
===
=== USER Question: Did you see this question? Are you ready to begin work?
Answer: Yes! I saw the question and I'm ready to begin work. The hooks are working correctly - I was notified when questions.md was modified. I have a todo list with 14 tasks for the dotfiles refactoring, starting with removing the old shellrc.d sourcing logic from ~/.zshrc. Ready to proceed!
===
===
=== [USER|AI] Question: ...
Answer: ...
===
