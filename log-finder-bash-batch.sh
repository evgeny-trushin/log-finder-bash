#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}${WHITE}🔍 Batch search for files and directories...${NC}"

# Reset search results file
OUTPUT_FILE="$HOME/search_results.txt"
echo -e "${YELLOW}🗑️  Resetting search results file...${NC}"
> "$OUTPUT_FILE"
echo -e "${GREEN}✅ Search results file reset: ${WHITE}${OUTPUT_FILE}${NC}"

echo "Define search patterns"
patterns=(
    "*.log"
    "*.log.*"
    "*logs*"
    "syslog*"
    "*.out"
    "*.err"
    "*.error"
    "*debug*"
    "*trace*"    
)

total_patterns=${#patterns[@]}
current_pattern=0

echo -e "${CYAN}📋 Running ${WHITE}${total_patterns}${CYAN} search patterns...${NC}"

for pattern in "${patterns[@]}"; do
    ((current_pattern++))
    echo -e "\n${BOLD}${YELLOW}[${current_pattern}/${total_patterns}]${NC} ${PURPLE}Searching files and directories for: ${WHITE}${pattern}${NC}"
                                 
    bash ./log-finder-bash.sh "${pattern}"
    
    echo -e "${GREEN}✅ Pattern '${pattern}' search completed${NC}"
done

echo -e "\n${BOLD}${GREEN}🎉 Batch search complete! All ${total_patterns} patterns processed.${NC}"
echo -e "${CYAN}📁 Results saved to: ${YELLOW}/Users/macbookpro/search_results.txt${NC}"