---
title: "[한영자막] 루프 자체가 제품입니다 — xAI 출신 창업자가 밝히는 차세대 AI 에이전트의 핵심"
source: "https://www.youtube.com/watch?v=cv2_Lzvd1mk"
author:
  - "[[Tech Bridge]]"
published: 2026-09-30
created: 2026-09-30
description: "xAI 출신이자 Introspection의 공동 창업자 롤랜드 가브릴레스쿠(Roland Gavrilescu)가 AI Engineer World's Fair에서 발표한 차세대 AI 에이전트 시스템 구축 전략입니다.단순한 프롬프트나 단일 모델 호출을 넘어, 스스로 개선되고 확장 가능한 상용 에이전트 제품을 만드는 세 가지 핵심 원칙을 제시합니다.📌 주"
tags:
  - "clippings"
---
![](https://www.youtube.com/watch?v=cv2_Lzvd1mk)

xAI 출신이자 Introspection의 공동 창업자 롤랜드 가브릴레스쿠(Roland Gavrilescu)가 AI Engineer World's Fair에서 발표한 차세대 AI 에이전트 시스템 구축 전략입니다.  
  
단순한 프롬프트나 단일 모델 호출을 넘어, 스스로 개선되고 확장 가능한 상용 에이전트 제품을 만드는 세 가지 핵심 원칙을 제시합니다.  
  
📌 주요 내용:  
• 루프 자체가 제품이다: OODA 루프 기반의 에이전트 사이클과 강력한 검증기(Verifier)의 중요성  
• 시스템 증류가 진정한 해자다: 프레임워크 종속 없이 지속 발전하는 '에이전트 레시피(Agent Recipes)'와 pi.recipes  
• 와트당 가치 있는 작업량: 실제 가치 창출과 경제적 효율성을 극대화하는 지표 최적화  
• 실전 사례: 인재 발굴 에이전트에서 인간 개입(Human-in-the-loop) 평가 보정과 A/B 테스트  
  
#AI에이전트 #인공지능 #Introspection #xAI #오토리서치 #LLM #개발자 #TechBridge  
  
⏱ 타임라인:  
00:00 도입부: xAI에서 Introspection으로  
00:51 오토리서치를 위한 청사진  
01:01 첫 번째 아이디어: 루프 자체가 제품이다  
01:36 최초의 에이전트 루프: OpenClaw로 자동차 가격 네고하기  
02:51 OODA 루프의 개념  
03:26 신호(Signal)와 검증기(Verifier)의 역할  
03:56 루프의 순환과 지속적 개선  
04:11 두 번째 아이디어: 시스템 증류가 곧 해자다  
04:51 AI 시스템을 위한 레시피  
05:35 에이전트 레시피: 재현 가능한 프런티어 시스템  
06:41 Introspection과 Pi 레시피(pi.recipes)  
09:05 세 번째 아이디어: 와트당 가치 있는 작업량  
10:35 제작자의 안목을 평가 지표로 코드화하기  
12:00 실전 사례: 인재 발굴(리크루팅) 에이전트  
13:05 실행 궤적(Trace)에서 패턴 포착하기  
13:55 인간 개입(HITL)을 통한 판정관 보정  
15:00 프로덕션에서 A/B 테스트로 안목 검증하기  
16:35 핵심 요약 및 시사점  
  
📎 관련 링크:  
• 롤랜드 가브릴레스쿠 X: https://x.com/rolandgvc  
• 롤랜드 가브릴레스쿠 LinkedIn: https://www.linkedin.com/in/roland-gavrilescu/  
• Introspection 공식 블로그: https://www.introspection.dev/blog

## Transcript

### 도입부: xAI에서 Introspection으로

**0:00** · Hello everyone.

**0:02** · How's everyone doing?

**0:04** · Woo! Are you guys ready for some more loops?

**0:08** · Yeah.

**0:10** · My name is Rowland. My co-founder and I were in this mythical place called XAI working hard on agent infra and we realized there's something new that has to be done in a standalone way. So, we left a few months ago to really figure out, okay, what's the next stage of how we should deploy these always-on, long-running horizon tasks.

**0:32** · Um, and I'm happy to announce we have a few findings that we would like to present you.

**0:39** · Um, and this talk is all about um, how you should productize these ideas in ways that can scale with your customers.

**0:48** · Um, you've heard a lot about auto research.

### 오토리서치를 위한 청사진

**0:52** · Um, we think there's a blueprint for 2026 and beyond on how you should think about auto research.

**0:58** · And it really comes down to three ideas.

### 첫 번째 아이디어: 루프 자체가 제품이다

**1:02** · Let's go through the first one.

**1:04** · The loop is the product.

**1:08** · We're all familiar with this.

**1:10** · We've started with everything goes down to RLHF for models and how you should train the model to become better and better reasoning. We then quickly moved to harnesses and how the model is a commodity and it's all about the harness.

**1:25** · And now we're talking about loops and how you should build these loops and not touch code anymore. But, what does it really mean and why is everyone saying that?

**1:35** · Do you guys remember Clawbot?

### 최초의 에이전트 루프: OpenClaw로 자동차 가격 네고하기

**1:38** · That was the original I original name of what is now now now known as Open Claw. And this guy, AJ, built the first loop around Clawbot.

**1:50** · What he did was to find a way to talk to dealers and talk to Reddit users to get bigger discounts on a car.

**1:59** · He followed these four steps.

**2:01** · Um and it's really open cloud the one that did it.

**2:05** · Go on Reddit, find prices, find inventory, talk to the dealers, put dealers head-to-head and try to figure out how to make them outbid each other, have a verifiable way to know when the price is right, and then lock in.

**2:25** · Get the car. And it worked. Um probably this was when all the Mac minis were uh selling off the shelves, but this was the first real example of loop is the product and something that probably should be a startup at this point. Um but we've seen how this became a recipe for everyone to build loops.

**2:47** · But let's take a step back. Why are we here?

**2:50** · Um we really think models have been trained with this loop in mind. And it comes from this idea of OODA loops.

### OODA 루프의 개념

**2:58** · It's a terminology coined back in 1970s by the US Air Force and is the idea of these um jet fighters of how to react in fast-paced environments.

**3:12** · If you think of models calling tools and taking observations, it's it's what we've been trained on uh as humans, but also as as agents now. Now, what happens when you put strong signals and verifiable work uh at the other ends.

### 신호(Signal)와 검증기(Verifier)의 역할

**3:29** · You get to these workers or cloud code agents. Um and and what matters here is the quality of the signal determines the uh success rate of the loop and the uh quality of the verifier um is able to calibrate uh if that success is actually correct or not.

**3:52** · But there's another loop here. Um what happens when you take that and feed it back into the signal? And this is what looping around is all about is how do you generate these artifacts at the end of the first loop to then run a second loop on and have a way to continuously improve.

### 루프의 순환과 지속적 개선

### 두 번째 아이디어: 시스템 증류가 곧 해자다

**4:11** · And this goes to my second point. System distillation is the moat.

**4:16** · And it's really the ability to understand what went well and wrong in the first loop and know how to process that in the second one.

**4:27** · So, how do we tune these AI systems?

**4:30** · Each loop generates useful information around harnesses, profiles, evals, models, resources, tools, and the environment.

**4:39** · What you really want is to have a way to keep this portable, to have a way to version this, and to evolve it over time.

**4:49** · If you think about data recipes in research, this is how RL started to work really well. You understood the recipes and how to continuously change the recipe to combat some of the behaviors that may happen around hallucinations, around reward hacking, and then you get to your stack, which is your final data recipe.

### AI 시스템을 위한 레시피

**5:10** · We don't have that for harnesses. We don't have that for like AI systems in the general term.

**5:15** · So, we thought there's space for something like that, something that contains the evals and contains the tweaks and the human judgment and all these things that are not predetermined at the beginning, but they're defined as you learn more about your agent acting in the in in in the environment.

**5:34** · We think recipes can be applied to this, and we should use the same name.

### 에이전트 레시피: 재현 가능한 프런티어 시스템

**5:38** · So, an agent recipe is really something that enables you to create reproducible frontier AI systems.

**5:45** · It's something that allows you to have a moat that keeps getting better over time, which is not tied to any platform or any provider. It's something that you control, lives in your company, and is agnostic to the models and providers you use.

**6:03** · And Loops should focus on this. Loops should be the way you distill these systems into recipes.

**6:09** · Failure patterns should become judges and evals. Repeated behavior should become skills and prompts. User frustration, extensions and memories to your harness, and so on.

**6:19** · You We're all familiar with this, but we didn't have the the the right like terminology of how we should think about it and how we should define it. And we think recipes is a way to put everything together into a Git repo and treat it as your ongoing um strategy for for uh building these self-improving systems. So, we are introspection, but you can think of introspection as the way you generate these recipes. So, they're recipes for introspecting on your on your system.

### Introspection과 Pi 레시피(pi.recipes)

**6:52** · We wanted to build something that is portable and provider agnostic. So, we built our um approach to recipes on the Pie Harness and on Harbor for evals.

**7:04** · We baked it into uh Git repos. So, uh everything could be versioned and agents would have a way to continuously track how this change and why, and is meant to be owned by you, but managed by your agents. And this is how products should really be built going forward. It's something that treats the owner as the um almost like the the the higher taste um personality in the room, but agents should try to calibrate themselves to to the taste of the of the maker.

**7:37** · So, we think recipes should be basically encoding the taste of the makers into how you build these agents. And if I want to use someone else's recipe, I should be able to also bring that taste.

**7:49** · It's not just the harness, it's not just the model, it's how did you arrive at this particular recipe and why? And that's kind of like what what is behind reproducible um products and services around agents. Um we have an early release of recipes.

**8:07** · It's called pi.recipes. It's very similar to skills uh used to be in 2025, but it's going a step forward. And this is what do I need to have a frontier agent? It's everything about how do I codify taste into evals? How do I run evals? How do we have the loops to continuously improve those evals over time? How do we process signals and know what are the right signals to to use? Um what are the right tools to work with certain models? How do I have different profiles of the harness to work with different models?

**8:38** · Um and everything in between.

**8:42** · So, have a look at what we've been building here. It's still early, uh but hopefully it's useful enough for you guys to to get going. And we feel this is going to grow into something that um really allows you to to use uh different um almost like different the to to be able to use the taste of of different makers uh as recipes for your agent.

### 세 번째 아이디어: 와트당 가치 있는 작업량

**9:05** · And finally, the last point is valued work per watt. And why is this the score to really optimize for? Think of how um Cursor and Cognition went from building the best product to then uh building the best evals for the product, and finally building the best models based on the previous two artifacts.

**9:25** · We think this is like the recipe for everything going forward. Um code was the first domain where this um was successful. Um everything beyond customer for legal, research, um everything is going to come down to this idea, how much value am I getting per watt? Um how do I measure the value is the first step, and how do I know I'm getting a good deal on that value is the second.

**9:51** · And maybe this makes it a bit more clear. We've all started from a base uh harness and a base set of evals, and we went to go to the frontier. Um and you only go through that by running the systems in prod. There's no way you you know what frontier is before you uh you start.

**10:09** · Um but the the the last step here, which is what is requiring a lot of research, um is, okay, once you've reached frontier, how do we make this um uh economically viable, which is how do we not spend more than than uh we need for generating this amount of value. Um and we think we have the building blocks now to make this accessible and pretty efficient.

**10:33** · In the sense of you've seen all these uh fine-tuning APIs, all the infrastructure that has been uh abstracted away for you to do do this process. It's just that the know-how that uh is not there yet.

### 제작자의 안목을 평가 지표로 코드화하기

**10:46** · And this is what we we we hope we can like push for. The know-how for knowing how to codify taste into evals and how to validate that in experiments. Um and you you've you've heard a lot about evals and experiments before, but you didn't really think of them of like, what are they? It's It's not just tests.

**11:03** · It's It's really what is the taste of the creator that agents should be able to reproduce and self-improve around.

**11:12** · And no one has thought of how do I make this as portable enough? How How do I make my taste as an artist or as a software developer um something that anyone can download in their brain and be able to be a one-to-one replica to me. And this is kind of like what RL is is is about now is how do we uh turn these um tastemakers into environments and evals around them so then we can move them into the weights. But there's more than that.

**11:42** · Um you can think of the worker as the inner loop and it generates all these artifacts. But how you look at the artifacts and know what to change is the taste. Uh and this is what creates candidates of what you should change and how you should adapt based on that. And experiments is what how you self-calibrate that okay, my taste is actually validated in production with users.

### 실전 사례: 인재 발굴(리크루팅) 에이전트

**12:06** · And we make sure that not only the maker is happy through the um offline evals, but the end users are happy as well and they agree with what we consider good.

**12:18** · Let's go through a practical example of how this works.

**12:23** · Let's take a baseline um agent, which could be a talent sourcing agent. Um and this is a very classical case of everyone is doing recruiting differently and is very much about not what is good recruiting, but who is leading that recruiting that considers recruiting is good.

**12:43** · So in this case, we're starting with something very simple, um a bunch of tools, web search, LinkedIn, uh a bunch of sub agents that have been pre-popularized by harnesses like Codex and Cloud Code, and uh system instruction, which is about your uh recruiter.

**13:02** · First step is really understand the signals.

### 실행 궤적(Trace)에서 패턴 포착하기

**13:05** · So you can think of patterns as being a way to look at the traces, extract some common um behaviors or common user frustrations, and turn them into like a cluster.

**13:17** · So let's say this idea of uh the agent is going uh and reaching out to a lot of big tech employees.

**13:23** · As a recruiter, you don't really want that. You want to find hidden gems. You don't want to try to hire John Carmack, but an agent would think that's oh, John Carmack is great. Why would I not reach out to him? Um so so this is a behavior that you you'd never think of codifying, but you discover the agent tends to be that.

**13:43** · Um Patterns is how you discover the signals and inform you what you should do next.

**13:50** · Um Calibration judges and evals is how we used to think about how do we qualify uh these these behaviors into um something that can try to uh apply the same judgment across traces and across uh execution.

### 인간 개입(HITL)을 통한 판정관 보정

**14:06** · So let's say we we build an agent that looks at a trajectory and um identifies exactly that pattern. Hey, did did this agent reach out to Google employees instead of trying to uh find hidden gems on GitHub?

**14:20** · Um and the calibration bit and the eval generation bit is not that hard. It it should be doable by agents to build. You just need a human in the loop to say, "Hey, um this is the approach we're taking. Do you agree with this judgment? Do you really agree that we should look more towards hidden gems rather than reach out to um um big tech employees?" And that's about it. You don't need the human to actually build the evals. You need them to calibrate the evals.

**14:51** · And agents should be the ones that really take the the the taste of the maker and and put them in into code.

**14:57** · Once you have this, it's pretty easy to create recipe candidates. And this should be the the diffs that you really want to taste. Um and you can have a pretty good offline eval set around this, but the the the test here is when you go to prod. So do the end user agree with your taste of not hitting up um big tech uh employees, right?

### 프로덕션에서 A/B 테스트로 안목 검증하기

**15:20** · And this is kind of like what you want is you build a product that really emphasizes your taste and then you you make sure that your users appreciate and value that taste. And AB tests have been a way to to to make sure that that's the case.

**15:36** · Um so, with a multi-arm bandit um scenario, for example, you you'd be able to do that pretty well. So, once you validate, "Okay, I have great taste and my users believe uh I have great taste as well." That's when you promote and that's kind of the when you go to to the next version of an agent recipe.

**15:54** · The secret is you keep doing this over and over again and you know how to continuously codify your taste and your um what what what good is to you into an agent that can reproduce the same service or product uh for other people and they also agree you have great great taste and you have great execution. And this is really kind of like the the secret of building good loops is, "Okay, can can someone iterate on my um system in a way as a you know, um a good example here is like Miranda from uh The Devil Wears Prada, right?

**16:25** · What would Miranda do uh in certain cases? And you kind of want to codify that that thinking into like agents that can do the same stuff at the higher level.

### 핵심 요약 및 시사점

**16:36** · So, the takeaways are this. Um the loop is the product. You try to automate yourself as the uh as the um higher level judge and you want to make sure your second-loop agents are able to apply the same judgment to your to the agents you're trying to to to push the product.

**16:54** · Second bit, system distillation is the moat. So, how do you continuously inject that taste into these uh workers and they how how they continuously self-verify and work together is uh the biggest thing that you should focus on and the faster you do it uh the the the faster you you build a defensible um approach to to becoming a vertical AI company.

**17:16** · And finally, value of work per watt is how you should measure um Am I making progress or not? So, first, make sure that the the the work you're generating is valuable. Second, make sure that the economics make sense. And the the the difference in price is is basically what people would would switch away from cloud code to to something you provide.

**17:40** · We've been thinking a lot about these ideas and we're building some very interesting products around how to deploy this in production. We'd love to hear from you. We'd love to get to to understand more about how how certain vertical SaaS companies are are looking to go to prod with or how agent labs have been thinking about this idea of creating these like auto research labs around their their own products.

**18:07** · Get in touch. We're going to be around the block for for chatting more about this and thank you very much.