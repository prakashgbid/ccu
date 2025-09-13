#!/usr/bin/env python3
"""
Demo: Prompt and Choice Logging with Pattern Learning
Shows how CC logs all prompts and user choices
"""
import sys
import time
import json
from pathlib import Path

# Add path for imports
sys.path.append(str(Path.home() / ".claude"))
from prompt_choice_logger import PromptChoiceLogger

def demo():
    print("="*60)
    print("🎯 PROMPT & CHOICE LOGGING DEMONSTRATION")
    print("="*60)
    print("\nThis system logs ALL prompts CC shows and choices you make")
    print("for pattern learning and backtracking.\n")
    
    # Initialize logger
    logger = PromptChoiceLogger()
    
    # Simulate CC showing prompts and user making choices
    print("📝 Simulating CC session with prompts...\n")
    
    # Prompt 1: Framework selection
    prompt1_id = logger.log_prompt(
        prompt_type="framework_selection",
        prompt_text="Which JavaScript framework should we use for the new project?",
        options=["React", "Vue", "Angular", "Svelte"],
        context={"project": "e-commerce", "team_size": 5}
    )
    time.sleep(0.5)
    logger.log_choice(prompt1_id, "React", reasoning="Team has most experience with React")
    
    # Prompt 2: Database choice
    prompt2_id = logger.log_prompt(
        prompt_type="database_selection",
        prompt_text="Select the database for the application:",
        options=["PostgreSQL", "MongoDB", "MySQL", "DynamoDB"],
        context={"data_type": "relational", "scale": "medium"}
    )
    time.sleep(0.3)
    logger.log_choice(prompt2_id, "PostgreSQL", reasoning="Need ACID compliance and complex queries")
    
    # Prompt 3: Deployment platform
    prompt3_id = logger.log_prompt(
        prompt_type="deployment_platform",
        prompt_text="Where should we deploy the application?",
        options=["AWS", "Google Cloud", "Azure", "Vercel"],
        context={"budget": "medium", "region": "us-east"}
    )
    time.sleep(0.4)
    logger.log_choice(prompt3_id, "AWS", reasoning="Better integration with existing infrastructure")
    
    # Prompt 4: CI/CD tool
    prompt4_id = logger.log_prompt(
        prompt_type="cicd_selection",
        prompt_text="Which CI/CD tool should we use?",
        options=["GitHub Actions", "Jenkins", "CircleCI", "GitLab CI"]
    )
    time.sleep(0.2)
    logger.log_choice(prompt4_id, "GitHub Actions", reasoning="Native integration with GitHub")
    
    # Prompt 5: Testing framework
    prompt5_id = logger.log_prompt(
        prompt_type="testing_framework",
        prompt_text="Select testing framework:",
        options=["Jest", "Mocha", "Vitest", "Cypress"]
    )
    time.sleep(0.3)
    logger.log_choice(prompt5_id, "Jest", reasoning="Works well with React")
    
    print("\n✅ Logged 5 prompts and choices\n")
    
    # Show backtracking
    print("="*60)
    print("📜 BACKTRACKING - Last 5 Prompts:")
    print("="*60)
    logger.backtrack(last_n=5)
    
    # Show pattern analysis
    print("\n" + "="*60)
    print("📊 PATTERN ANALYSIS:")
    print("="*60)
    analysis = logger.analyze_patterns()
    print(json.dumps(analysis, indent=2))
    
    # Show how to find specific prompts
    print("\n" + "="*60)
    print("🔍 SEARCHING for 'database' prompts:")
    print("="*60)
    logger.backtrack(search_term="database", last_n=20)
    
    # Save patterns for CLS learning
    logger._save_patterns()
    print("\n✅ Patterns saved for CLS learning")
    
    # Show console log file location
    console_log = logger.console_log
    print(f"\n📁 Full console log saved at:")
    print(f"   {console_log}")
    print(f"\n📁 Pattern file for CLS:")
    print(f"   {logger.pattern_file}")
    
    print("\n" + "="*60)
    print("🎯 KEY FEATURES:")
    print("="*60)
    print("1. Every prompt CC shows is logged with timestamp")
    print("2. Every user choice is tracked with reasoning")
    print("3. Response times are measured for pattern learning")
    print("4. CLS learns from patterns to predict future choices")
    print("5. You can backtrack to any previous prompt/choice")
    print("6. Search through prompt history by keywords")
    print("7. Replay entire sessions for review")
    print("\n💡 Use 'pback' command to backtrack prompts in terminal")

if __name__ == "__main__":
    demo()