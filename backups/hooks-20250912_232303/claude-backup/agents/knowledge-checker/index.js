#!/usr/bin/env node

/**
 * Knowledge Checker Agent - REALISTIC Implementation
 * Checks CKS before code generation using simple, working methods
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();

class KnowledgeCheckerAgent {
    constructor() {
        this.cksDb = '/Users/MAC/Documents/projects/caia/knowledge-system/data/knowledge.db';
        this.patternsDb = '/Users/MAC/Documents/projects/caia/knowledge-system/data/patterns.db';
    }

    /**
     * Check for existing code before generation
     * REALISTIC: Uses simple SQL queries and grep
     */
    async checkForDuplicates(query) {
        const results = {
            duplicates: [],
            suggestions: [],
            patterns: []
        };

        // Extract key terms from query (SIMPLE)
        const keywords = query.toLowerCase()
            .match(/\b[a-z]+[a-z0-9]*\b/gi)
            .filter(word => word.length > 3);

        // Search in CKS database (WORKS)
        const db = new sqlite3.Database(this.cksDb);
        
        return new Promise((resolve) => {
            db.all(
                `SELECT file_path, name, type FROM components 
                 WHERE name LIKE ? OR file_path LIKE ? 
                 LIMIT 10`,
                [`%${keywords[0]}%`, `%${keywords[0]}%`],
                (err, rows) => {
                    if (!err && rows) {
                        results.duplicates = rows;
                    }
                    
                    // Also use ripgrep for file search (FAST & WORKS)
                    try {
                        const rgResult = execSync(
                            `rg -l "${keywords[0]}" /Users/MAC/Documents/projects --max-count=5 2>/dev/null | head -5`,
                            { encoding: 'utf8' }
                        ).trim();
                        
                        if (rgResult) {
                            results.suggestions = rgResult.split('\n');
                        }
                    } catch (e) {
                        // Ignore grep errors
                    }
                    
                    db.close();
                    resolve(results);
                }
            );
        });
    }

    /**
     * Learn from new code generation
     * REALISTIC: Simple pattern counting
     */
    async learnPattern(code, filePath) {
        const db = new sqlite3.Database(this.patternsDb);
        
        // Extract simple patterns (WORKS)
        const patterns = {
            hasAsync: code.includes('async'),
            hasClass: /class\s+\w+/.test(code),
            hasFunction: /function\s+\w+/.test(code),
            fileType: path.extname(filePath)
        };
        
        // Store patterns (SIMPLE)
        Object.entries(patterns).forEach(([key, value]) => {
            if (value) {
                db.run(
                    `INSERT OR REPLACE INTO behavior_patterns 
                     (pattern_type, pattern_data, frequency)
                     VALUES ('code_pattern', ?, 
                        COALESCE((SELECT frequency FROM behavior_patterns 
                                  WHERE pattern_type='code_pattern' 
                                  AND pattern_data=?), 0) + 1)`,
                    [key, key]
                );
            }
        });
        
        db.close();
    }

    /**
     * Main execution
     */
    async execute(prompt) {
        console.log('🔍 Knowledge Checker Agent Activated');
        
        // Check for duplicates
        const results = await this.checkForDuplicates(prompt);
        
        if (results.duplicates.length > 0) {
            console.log('\n⚠️  Similar code found in CKS:');
            results.duplicates.forEach(item => {
                console.log(`  • ${item.name} in ${item.file_path}`);
            });
        }
        
        if (results.suggestions.length > 0) {
            console.log('\n💡 Related files found:');
            results.suggestions.forEach(file => {
                console.log(`  • ${file}`);
            });
        }
        
        // Return actionable advice
        if (results.duplicates.length > 0 || results.suggestions.length > 0) {
            return {
                status: 'found_existing',
                message: 'Consider reusing existing code',
                data: results
            };
        }
        
        return {
            status: 'no_duplicates',
            message: 'No existing code found, safe to create new',
            data: results
        };
    }
}

// CLI interface
if (require.main === module) {
    const agent = new KnowledgeCheckerAgent();
    const prompt = process.argv.slice(2).join(' ') || 'test query';
    
    agent.execute(prompt).then(result => {
        console.log(JSON.stringify(result, null, 2));
    });
}

module.exports = KnowledgeCheckerAgent;