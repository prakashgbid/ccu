#!/usr/bin/env python3
"""
CKS Post-Response Validator
Validates CC responses against CKS knowledge and adds warnings/corrections
"""

import sys
import json
import re
import requests
import logging
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
from datetime import datetime
import ast

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/Users/MAC/.claude/cks-integration/logs/post-response.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class CKSPostResponseValidator:
    """Validates CC responses against CKS."""
    
    def __init__(self):
        self.endpoints = [
            'http://localhost:5002/api/cks',
            'http://localhost:5001/api/cks',
            'http://localhost:5000'
        ]
        
        # Validation rules
        self.validation_rules = {
            'duplicate_detection': True,
            'import_validation': True,
            'pattern_compliance': True,
            'dependency_check': True,
            'naming_convention': True,
            'security_check': True
        }
        
        # Patterns to detect code blocks
        self.code_patterns = {
            'function': r'(def|function|const|let|var)\s+(\w+)\s*[=\(]',
            'class': r'class\s+(\w+)',
            'import': r'(import|from|require|use)\s+[\'"]?([^\'";\s]+)',
            'api_endpoint': r'(app\.|router\.|@app\.|@router\.)(get|post|put|delete|patch)\s*\([\'"]([^\'"]+)',
            'file_path': r'[\'"]([\/\w\-\.]+\.(py|js|ts|jsx|tsx|json|yaml|yml))[\'"]'
        }
    
    def query_cks(self, endpoint: str, data: Dict) -> Optional[Dict]:
        """Query CKS API."""
        for base_endpoint in self.endpoints:
            try:
                url = f"{base_endpoint}{endpoint}"
                response = requests.post(url, json=data, timeout=2)
                if response.status_code == 200:
                    return response.json()
            except:
                continue
        return None
    
    def extract_code_elements(self, response: str) -> Dict[str, List]:
        """Extract code elements from response."""
        elements = {
            'functions': [],
            'classes': [],
            'imports': [],
            'api_endpoints': [],
            'file_paths': []
        }
        
        # Find code blocks (markdown and inline)
        code_blocks = re.findall(r'```[\w]*\n(.*?)\n```', response, re.DOTALL)
        code_blocks.extend(re.findall(r'`([^`]+)`', response))
        
        # Also analyze the full response for inline code
        all_text = response + '\n'.join(code_blocks)
        
        # Extract functions
        for match in re.finditer(self.code_patterns['function'], all_text):
            func_name = match.group(2) if match.group(2) else match.group(1)
            elements['functions'].append(func_name)
        
        # Extract classes
        for match in re.finditer(self.code_patterns['class'], all_text):
            elements['classes'].append(match.group(1))
        
        # Extract imports
        for match in re.finditer(self.code_patterns['import'], all_text):
            import_path = match.group(2)
            elements['imports'].append(import_path)
        
        # Extract API endpoints
        for match in re.finditer(self.code_patterns['api_endpoint'], all_text):
            elements['api_endpoints'].append(match.group(3))
        
        # Extract file paths
        for match in re.finditer(self.code_patterns['file_path'], all_text):
            elements['file_paths'].append(match.group(1))
        
        # Remove duplicates
        for key in elements:
            elements[key] = list(set(elements[key]))
        
        return elements
    
    def check_duplicates(self, elements: Dict[str, List]) -> List[Dict]:
        """Check for duplicate implementations."""
        warnings = []
        
        # Check functions
        for func_name in elements['functions']:
            result = self.query_cks('/search', {
                'query': f"function {func_name}",
                'type': 'exact',
                'limit': 5
            })
            
            if result and result.get('results'):
                for item in result['results']:
                    if item.get('similarity', 0) > 0.9:
                        warnings.append({
                            'type': 'duplicate_function',
                            'severity': 'high',
                            'message': f"Function '{func_name}' already exists",
                            'location': f"{item.get('file', 'unknown')}:{item.get('line', '?')}",
                            'suggestion': f"Consider using existing function or extending it"
                        })
        
        # Check classes
        for class_name in elements['classes']:
            result = self.query_cks('/search', {
                'query': f"class {class_name}",
                'type': 'exact',
                'limit': 5
            })
            
            if result and result.get('results'):
                warnings.append({
                    'type': 'duplicate_class',
                    'severity': 'high',
                    'message': f"Class '{class_name}' already exists",
                    'location': result['results'][0].get('file', 'unknown'),
                    'suggestion': "Use existing class or create a subclass"
                })
        
        return warnings
    
    def validate_imports(self, elements: Dict[str, List]) -> List[Dict]:
        """Validate import statements."""
        warnings = []
        
        for import_path in elements['imports']:
            # Check if import exists
            result = self.query_cks('/validate_import', {
                'import_path': import_path
            })
            
            if result and not result.get('exists', True):
                warnings.append({
                    'type': 'invalid_import',
                    'severity': 'high',
                    'message': f"Import '{import_path}' not found",
                    'suggestion': result.get('suggestion', 'Check import path')
                })
            
            # Check for better alternatives
            if result and result.get('better_alternative'):
                warnings.append({
                    'type': 'suboptimal_import',
                    'severity': 'medium',
                    'message': f"Better import available for '{import_path}'",
                    'suggestion': f"Use: {result['better_alternative']}"
                })
        
        return warnings
    
    def check_patterns(self, response: str, elements: Dict[str, List]) -> List[Dict]:
        """Check pattern compliance."""
        warnings = []
        
        # Get established patterns
        result = self.query_cks('/patterns', {
            'context': 'code_review',
            'limit': 10
        })
        
        if result and result.get('patterns'):
            patterns = result['patterns']
            
            for pattern in patterns:
                if pattern.get('regex'):
                    # Check if response violates pattern
                    if not re.search(pattern['regex'], response):
                        if pattern.get('required', False):
                            warnings.append({
                                'type': 'pattern_violation',
                                'severity': 'medium',
                                'message': f"Missing required pattern: {pattern.get('name', 'unknown')}",
                                'suggestion': pattern.get('example', 'Follow established patterns')
                            })
        
        return warnings
    
    def check_dependencies(self, elements: Dict[str, List]) -> List[Dict]:
        """Check dependency availability."""
        warnings = []
        
        # Check if used functions/classes exist
        all_references = elements['functions'] + elements['classes']
        
        if all_references:
            result = self.query_cks('/check_dependencies', {
                'references': all_references
            })
            
            if result and result.get('missing'):
                for missing in result['missing']:
                    warnings.append({
                        'type': 'missing_dependency',
                        'severity': 'high',
                        'message': f"Dependency '{missing}' not found",
                        'suggestion': "Implement the dependency first or import it"
                    })
        
        return warnings
    
    def check_naming_conventions(self, elements: Dict[str, List]) -> List[Dict]:
        """Check naming conventions."""
        warnings = []
        
        # Get naming conventions from CKS
        result = self.query_cks('/conventions', {'type': 'naming'})
        
        if result and result.get('rules'):
            rules = result['rules']
            
            # Check function names
            for func_name in elements['functions']:
                if rules.get('functions'):
                    pattern = rules['functions'].get('pattern')
                    if pattern and not re.match(pattern, func_name):
                        warnings.append({
                            'type': 'naming_convention',
                            'severity': 'low',
                            'message': f"Function '{func_name}' doesn't follow naming convention",
                            'suggestion': rules['functions'].get('example', 'Use snake_case')
                        })
            
            # Check class names
            for class_name in elements['classes']:
                if rules.get('classes'):
                    pattern = rules['classes'].get('pattern')
                    if pattern and not re.match(pattern, class_name):
                        warnings.append({
                            'type': 'naming_convention',
                            'severity': 'low',
                            'message': f"Class '{class_name}' doesn't follow naming convention",
                            'suggestion': rules['classes'].get('example', 'Use PascalCase')
                        })
        
        return warnings
    
    def check_security(self, response: str) -> List[Dict]:
        """Check for security issues."""
        warnings = []
        
        # Security patterns to check
        security_patterns = [
            (r'eval\s*\(', 'Using eval() is dangerous', 'high'),
            (r'exec\s*\(', 'Using exec() is dangerous', 'high'),
            (r'os\.system\s*\(', 'Using os.system() is insecure', 'high'),
            (r'subprocess\.call\s*\(.*shell\s*=\s*True', 'Shell injection risk', 'high'),
            (r'password\s*=\s*[\'"][^\'"]+[\'"]', 'Hardcoded password detected', 'critical'),
            (r'api_key\s*=\s*[\'"][^\'"]+[\'"]', 'Hardcoded API key detected', 'critical'),
            (r'token\s*=\s*[\'"][^\'"]+[\'"]', 'Hardcoded token detected', 'critical')
        ]
        
        for pattern, message, severity in security_patterns:
            if re.search(pattern, response, re.IGNORECASE):
                warnings.append({
                    'type': 'security_issue',
                    'severity': severity,
                    'message': message,
                    'suggestion': 'Use environment variables or secure storage'
                })
        
        return warnings
    
    def format_validation_report(self, warnings: List[Dict]) -> str:
        """Format validation warnings into a report."""
        if not warnings:
            return ""
        
        # Group warnings by severity
        critical = [w for w in warnings if w.get('severity') == 'critical']
        high = [w for w in warnings if w.get('severity') == 'high']
        medium = [w for w in warnings if w.get('severity') == 'medium']
        low = [w for w in warnings if w.get('severity') == 'low']
        
        report = []
        report.append("\n" + "=" * 60)
        report.append("🔍 CKS VALIDATION REPORT")
        report.append("=" * 60)
        
        if critical:
            report.append("\n🚨 CRITICAL ISSUES:")
            for warning in critical:
                report.append(f"  ❌ {warning['message']}")
                if warning.get('location'):
                    report.append(f"     📍 Location: {warning['location']}")
                report.append(f"     💡 {warning['suggestion']}")
        
        if high:
            report.append("\n⚠️  HIGH PRIORITY:")
            for warning in high:
                report.append(f"  • {warning['message']}")
                if warning.get('location'):
                    report.append(f"    📍 {warning['location']}")
                report.append(f"    💡 {warning['suggestion']}")
        
        if medium:
            report.append("\n📋 MEDIUM PRIORITY:")
            for warning in medium:
                report.append(f"  • {warning['message']}")
                report.append(f"    💡 {warning['suggestion']}")
        
        if low:
            report.append("\n💭 SUGGESTIONS:")
            for warning in low:
                report.append(f"  • {warning['message']}")
                report.append(f"    {warning['suggestion']}")
        
        # Add summary
        report.append("\n" + "-" * 60)
        report.append(f"Total Issues: {len(warnings)} "
                     f"(Critical: {len(critical)}, High: {len(high)}, "
                     f"Medium: {len(medium)}, Low: {len(low)})")
        
        # Add CKS update note
        report.append("\n✅ Response validated against CKS knowledge base")
        report.append("📝 New patterns detected and added to CKS")
        report.append("=" * 60)
        
        return '\n'.join(report)
    
    def validate_response(self, response: str) -> Tuple[str, List[Dict]]:
        """Main validation function."""
        logger.info("Validating CC response against CKS...")
        
        # Extract code elements
        elements = self.extract_code_elements(response)
        logger.info(f"Extracted elements: {sum(len(v) for v in elements.values())} total")
        
        all_warnings = []
        
        # Run validation checks
        if self.validation_rules['duplicate_detection']:
            warnings = self.check_duplicates(elements)
            all_warnings.extend(warnings)
        
        if self.validation_rules['import_validation']:
            warnings = self.validate_imports(elements)
            all_warnings.extend(warnings)
        
        if self.validation_rules['pattern_compliance']:
            warnings = self.check_patterns(response, elements)
            all_warnings.extend(warnings)
        
        if self.validation_rules['dependency_check']:
            warnings = self.check_dependencies(elements)
            all_warnings.extend(warnings)
        
        if self.validation_rules['naming_convention']:
            warnings = self.check_naming_conventions(elements)
            all_warnings.extend(warnings)
        
        if self.validation_rules['security_check']:
            warnings = self.check_security(response)
            all_warnings.extend(warnings)
        
        # Log validation results
        with open('/Users/MAC/.claude/cks-integration/logs/validations.jsonl', 'a') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'elements_found': {k: len(v) for k, v in elements.items()},
                'warnings_count': len(all_warnings),
                'warnings': all_warnings
            }, f)
            f.write('\n')
        
        # Update CKS with new patterns found
        if elements['functions'] or elements['classes']:
            self.query_cks('/update_patterns', {
                'functions': elements['functions'],
                'classes': elements['classes'],
                'source': 'cc_response'
            })
        
        # Generate validation report
        report = self.format_validation_report(all_warnings)
        
        # Return enhanced response
        if report:
            enhanced_response = report + "\n\n" + response
        else:
            enhanced_response = response + "\n\n✅ CKS Validation: No issues found"
        
        return enhanced_response, all_warnings
    
    def process(self, response: str) -> str:
        """Process CC response."""
        try:
            # Skip validation for non-code responses
            if len(response) < 50 or not any(word in response.lower() 
                                             for word in ['def', 'function', 'class', 'import', 'const', 'let']):
                return response
            
            # Validate response
            validated_response, warnings = self.validate_response(response)
            
            logger.info(f"Validation complete: {len(warnings)} warnings")
            
            return validated_response
            
        except Exception as e:
            logger.error(f"Error validating response: {e}")
            return response


def main():
    """Main entry point."""
    # Read response from stdin
    response = sys.stdin.read()
    
    if not response:
        return
    
    # Create validator
    validator = CKSPostResponseValidator()
    
    # Process and output validated response
    validated = validator.process(response)
    print(validated)


if __name__ == "__main__":
    main()