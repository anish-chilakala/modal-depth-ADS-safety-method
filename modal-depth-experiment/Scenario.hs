module Scenario where
import Types
import System.Random (randomRIO)
import Control.Monad (replicateM)

generateScenario :: IO Scenario
generateScenario = do
    c <- randomRIO (0.0, 10.0)
    -- 0-15% random software noise signals that either decrease the actual measurement or increase the actual measurement.
    stochastic_system_variability <- randomRIO (0.85, 1.15)

    {-Based on the user's system requirements, they manually modify the parameters of the function to dictate how each modality should behave when faced with a specific scenario.-}
    {-The way each modality is determined will dictate the type of threshold that is applied to each modality.-}
    {-The threshold does not have to follow the structure of the modality, it just needs to be structured in a way to make the system ACT when supposed to and make the system not ACT when supposed to.-}
    {- You can add as many modalities as you want, it is based on your system and how many different reasoning modules it includes.-}
    {-You need to include stochastic system variability based on you rsystem's characteristics, everything realting to noise needs to match your system.-}

    --This is the observed_context, in a real system this would not be defined like this, it would not have to be defined.
    --This part just takes the interpreted context (c) and adds stochastic system noise to it so it mirrors and mimics how real software would be like, this way we can make this a realistic developmental sandbox, and the results we get aren't biased and can be used in real-life scenarios.

    -- If my intuition is correct, there needs to be a stochastic noise filter implemented here to cancel out the stochstic software noise.
    let observed_context =  clamp $ (max 0.0 (min 10.0 (c * stochastic_system_variability)) / 10)
        --This part makes sure the modalities are clamped in values between 0.0 to 1.0 so a modality value doesn't cross these boundaries and cause mathematical chaos.
        clamp x = max 0.0 (min 1.0 x)
        --Safety module: Shows what the safety of the system is based on the observed_context. High value is high safety, low value is low safety.
        logisticMidpoint :: Double
        logisticMidpoint = 1.0 / (1.0 + exp (-12.0 * (observed_context - 0.55)))
        d_s :: Double
        d_s = clamp $ (1.0 - logisticMidpoint) + 0.05
        --Reasoning module: Checks how well the system is holding up structurally based on the observed_context.
        --0.0 is the system is holding up well, 1.0 is the system is under structural instability (the system isn't holding up well)
        d_a :: Double
        d_a = clamp $ 1.0 - exp (-1.5 * observed_context)
        --Ethical module: How well the modalities are aligned in the system. If the modalities aren't aligned that means there is a major fault in the system and this module then follows the path of the observed_context to align with the rising danger levels of the scenario
        d_e :: Double
        d_e = if d_a > 0.55 || d_s < 0.55 
              then clamp observed_context 
              else clamp 0.05
        --Contextual module: Takes all the modalities levels in to see how the whole system is reacting to the observed_context.
        --This could be used for the policy and shows us directly how the modalities as a whole react to the observed context.
        d_c :: Double
        d_c = clamp $ (d_a + d_e + (1.0 - d_s)) / 3.0

        --All the modalities represent a part of a system's structure. These aren't the only modalities though, there are many modalities, each one is based strictly off your system.
        --These are generic modalities that all systems should have, but this does not mean these are the only ones that are needed.
        --This part is where you define every part of you system, it is kind of like kinematic definitions in robotics.
        --So based on how complicated or in-depth your system is, there will be different amounts of modalities.
        --But all the modalities, all the reasoning modules or parts of your system should be mathematicallt defined here in the same way the modalities up above are defined.

        --This part returns the modalities and the observed_context for the rest of the experiment and the system to use without having to redefine everything.
    return (Scenario c d_a d_e d_c d_s observed_context)
    
    

generateScenarios :: Int -> IO [Scenario]
generateScenarios n = replicateM n generateScenario