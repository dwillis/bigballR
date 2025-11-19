# bigballR Documentation Index

## Overview

This directory now contains comprehensive documentation for understanding and adapting the bigballR package for women's basketball.

---

## Documentation Files

### 1. **ANALYSIS.md** (14 KB)
Complete technical breakdown of the bigballR repository.

**Contents**:
- Repository structure and layout
- Data sources and URL patterns
- Detailed architecture and data flow
- All 19 exported functions with descriptions
- Key code patterns and technologies
- Data structure specifications
- Critical dependencies (Season IDs, Conference IDs, Team IDs)
- Recent updates and known fragilities
- What needs to change for women's basketball

**Best For**: Deep understanding of how the package works

---

### 2. **QUICK_REFERENCE.md** (9.7 KB)
Quick lookup guide for developers and users.

**Contents**:
- Function call stack (high to low level)
- Core data flow diagrams
- Key files to modify for WBB
- URL pattern references
- Season ID reference table
- Conference ID reference table
- HTML table structure details
- Team name extraction patterns
- Player name normalization examples
- Error handling patterns
- Testing checklist for WBB

**Best For**: Quick lookups while coding

---

### 3. **FUNCTION_SIGNATURES.md** (15 KB)
Complete reference for all function signatures and dependencies.

**Contents**:
- All 19 exported function signatures
- Function return values
- Function dependencies
- Complete call graph
- Data flow examples (3 workflows)
- Package imports and dependencies
- Common parameter patterns
- Critical code sections (fragile vs. robust)

**Best For**: Function reference and API documentation

---

### 4. **WBB_ADAPTATION_GUIDE.md** (8 KB)
Detailed implementation guide for women's basketball adaptation.

**Contents**:
- Executive summary
- Phase 1: Investigation (4 tasks)
- Phase 2: Implementation (6 tasks)
- Phase 3: Testing (3 tasks)
- Code modification summary
- Backward compatibility strategy
- Risk assessment
- Implementation timeline (18-23 hours)
- Success criteria
- Next steps

**Best For**: Implementation planning and execution

---

### 5. **Original Files** (in repository)
- **README.md** - Original package documentation
- **DESCRIPTION** - Package metadata
- **NAMESPACE** - Exported functions
- **LICENSE.md** - MIT License

---

## Quick Navigation

### By Task

**"I need to understand the codebase"**
→ Start with ANALYSIS.md sections 1-4

**"I need to implement women's basketball support"**
→ Follow WBB_ADAPTATION_GUIDE.md in order

**"I need to look up a specific function"**
→ Use FUNCTION_SIGNATURES.md

**"I need to find code patterns"**
→ Use QUICK_REFERENCE.md

**"I'm debugging a problem"**
→ Use ANALYSIS.md sections 8-9

---

### By Topic

**URLs & Data Sources**
- ANALYSIS.md section 3
- QUICK_REFERENCE.md URL Pattern Reference

**Architecture & Flow**
- ANALYSIS.md sections 4-5
- QUICK_REFERENCE.md Core Data Flow

**Functions & APIs**
- FUNCTION_SIGNATURES.md
- ANALYSIS.md section 11

**Configuration & IDs**
- ANALYSIS.md section 7
- QUICK_REFERENCE.md Season ID Reference
- QUICK_REFERENCE.md Conference ID Reference

**Women's Basketball Adaptation**
- WBB_ADAPTATION_GUIDE.md
- ANALYSIS.md section 9

---

## Key Concepts Summary

### Architecture Layers

1. **User API Layer** (19 exported functions)
   - Schedule retrieval: get_date_games, get_team_schedule
   - Scraping: scrape_game, scrape_box, get_play_by_play
   - Analysis: get_lineups, on_off_generator, get_player_stats
   - Visualization: plot_player_stints, plot_duos

2. **Data Processing Layer**
   - HTML parsing: XML::readHTMLTable()
   - String processing: stringr regex patterns
   - Data manipulation: dplyr operations
   - Event conversion: V1/V2 format normalization

3. **Data Source Layer**
   - NCAA stats.ncaa.org
   - Specific URL patterns for each data type
   - Hardcoded season IDs (15 years)
   - Hardcoded conference IDs (30+ conferences)

4. **Database Layer**
   - teamids.RData (team ID lookups)
   - conference_names file (conference mappings)

---

## Critical Information for WBB Adaptation

### Must Do First (Phase 1)
1. **Verify URLs** - Check if WBB uses same structure as MBB
2. **Find Season IDs** - Map dates to NCAA season IDs for WBB
3. **Build Team ID Database** - Create wbb_teamids.RData
4. **Test HTML Structure** - Verify table indices match

### Implementation Strategy (Phase 2)
1. Add `sport` parameter to 7 core functions
2. Refactor season ID logic into helper functions
3. Create team ID helper function
4. Build and include wbb_teamids dataset
5. Update documentation

### Key Dependencies to Update
- `R/all_functions.R` (lines 55-60: URLs; 1099-1227: season IDs; 1167-1200: conf IDs)
- `data/wbb_teamids.RData` (new file)
- `NAMESPACE` (add wbb_teamids export)

### Backward Compatibility
- All new parameters default to MBB behavior
- Existing code continues to work unchanged
- No changes to data structures
- No breaking changes

---

## File Locations in Repository

```
/home/user/bigballR/
├── R/
│   ├── all_functions.R (3,528 lines - main code)
│   ├── get_player_combos.R (player analysis)
│   └── plot_player_stints.R (visualization)
├── data/
│   └── teamids.RData (team ID lookup)
├── man/ (auto-generated documentation)
├── ANALYSIS.md (new - complete breakdown)
├── QUICK_REFERENCE.md (new - quick lookups)
├── FUNCTION_SIGNATURES.md (new - API reference)
├── WBB_ADAPTATION_GUIDE.md (new - implementation guide)
├── DOCUMENTATION_INDEX.md (this file)
├── README.md (original package docs)
├── DESCRIPTION (package metadata)
├── NAMESPACE (function exports)
└── LICENSE.md (MIT License)
```

---

## Statistics

| Metric | Value |
|--------|-------|
| Main function file | 3,528 lines |
| Exported functions | 19 |
| Data files | 1 + conference_names |
| Documentation files | 4 new |
| Test functions needed | 19 + workflows |
| Estimated adaptation time | 18-23 hours |
| Risk level | Low-Medium |

---

## Version Information

- **Package Name**: bigballR
- **Current Status**: Active (last MBB commit: Nov 10, 2024)
- **Branch**: claude/adapt-womens-basketball-012QveXFhcb912RKhhzb71o4
- **Documentation Created**: Nov 18, 2024
- **R Version Required**: >= 3.1.2
- **Key Dependencies**: dplyr, XML, stringr, ggplot2, igraph, ggraph, gtools, rvest

---

## How to Use This Documentation

### First Time Users
1. Read ANALYSIS.md sections 1-2 for context
2. Review FUNCTION_SIGNATURES.md to understand the API
3. Look at examples in QUICK_REFERENCE.md
4. Check README.md for basic usage

### Developers Adapting for WBB
1. Follow WBB_ADAPTATION_GUIDE.md Phase 1 (investigation)
2. Use ANALYSIS.md section 9 as reference
3. Follow WBB_ADAPTATION_GUIDE.md Phase 2-3 (implementation & testing)
4. Use QUICK_REFERENCE.md for code patterns

### Debugging Issues
1. Check ANALYSIS.md section 8 (recent updates)
2. Look at QUICK_REFERENCE.md error handling patterns
3. Review FUNCTION_SIGNATURES.md dependencies
4. Check which layer the error is in (data source, processing, API)

### Extending Functionality
1. Review FUNCTION_SIGNATURES.md dependencies
2. Check ANALYSIS.md data structures
3. Use existing function patterns from QUICK_REFERENCE.md
4. Maintain backward compatibility for MBB

---

## Questions & Answers

**Q: Will WBB support break MBB?**
A: No. All changes maintain backward compatibility with MBB.

**Q: How many functions need to be modified?**
A: 7 core scraping functions need `sport` parameter. 12 analysis functions need no changes.

**Q: What's the biggest unknown?**
A: URL structure - need to verify if WBB uses same format as MBB.

**Q: How long will it take?**
A: Estimated 18-23 hours total (3-5 days of work).

**Q: Where do I start?**
A: Follow Phase 1 of WBB_ADAPTATION_GUIDE.md.

**Q: What if NCAA's HTML structure differs for WBB?**
A: Low risk - just need to adjust table indices and parsing patterns (already done before for website changes).

---

## Support Resources

### Internal Documentation
- ANALYSIS.md - Deep technical details
- FUNCTION_SIGNATURES.md - API reference
- QUICK_REFERENCE.md - Common patterns
- WBB_ADAPTATION_GUIDE.md - Implementation guide

### External Resources
- [NCAA Stats](https://stats.ncaa.org/) - Data source
- [bigballR GitHub](https://github.com/jflancer/bigballR) - Original repo
- [R Packages Book](https://r-pkgs.org/) - Package development guide

### Key Files to Reference
- `/home/user/bigballR/R/all_functions.R` - Main source code
- `/home/user/bigballR/data/teamids.RData` - Team ID database
- `/home/user/bigballR/NAMESPACE` - Function exports

---

**Documentation last updated**: November 18, 2024
**Documentation version**: 1.0
**Target adaptation**: Women's Basketball (WBB)
