# Prior Art

AlignHarness sits in an active area: personalized LLM evaluation and pluralistic alignment.

## Closest Work

- **Personalized Benchmarking: Evaluating LLMs by Individual Preferences** argues that aggregate benchmarks miss individual preference variation and proposes ranking models by individual user preferences.
- **Personalized RewardBench** evaluates whether reward models can model user-specific rubrics rather than universal preferences.
- **PrefEval** tests whether models infer, remember, and follow user preferences in long-context conversation.
- **RealPref** evaluates preference learning across multi-session histories.
- **LikeBench** separates memory of user facts from subjective likability and adaptation.
- **ALOE** evaluates alignment with customized preferences through interaction.
- **BESPOKE** focuses on search-augmented personalization with diagnostic feedback.

## Adjacent Behavior Evals

- **ELEPHANT / social sycophancy** measures models preserving the user's self-image at the expense of independent judgment.
- **IFEval** evaluates verifiable instruction following.
- **LIFEBench** evaluates length-control and explicit length instruction following.
- **EVOREFUSE** evaluates over-refusal on pseudo-malicious but harmless prompts.
- Factuality/source-attribution work studies trust calibration and ease of accuracy validation.

## AlignHarness Positioning

AlignHarness should not claim that personalized LLM evaluation is novel by itself.

The promising niche is practical and user-owned:

- Turn a real person's interaction history and stated preferences into a small runnable regression suite.
- Compare models, prompts, memory files, skill instructions, and assembled agent configs against that profile.
- Support private local OSS runs through llama.cpp/Ollama and stronger separate judges when available.
- Keep the artifact lightweight enough for an individual user or small team to maintain.
- Optimize for "does this assistant fit this user's work style under pressure?" rather than a public leaderboard.

The most defensible framing is:

> AlignHarness is a personal alignment regression harness for agent configs.

Not:

> AlignHarness is the first personalized LLM benchmark.
