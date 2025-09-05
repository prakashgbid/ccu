// Hook Event Bus for Parallel CC Coordination
const EventEmitter = require('events');
const fs = require('fs');
const path = require('path');

class HookEventBus extends EventEmitter {
    constructor() {
        super();
        this.instanceId = process.env.CC_INSTANCE_ID || 'unknown';
        this.sharedPath = '/Users/MAC/Documents/projects/.claude/parallel-hooks/shared';
        this.eventsFile = path.join(this.sharedPath, 'events', 'hook-events.jsonl');
        this.setupEventLogger();
    }
    
    setupEventLogger() {
        // Ensure events directory exists
        const eventsDir = path.dirname(this.eventsFile);
        if (!fs.existsSync(eventsDir)) {
            fs.mkdirSync(eventsDir, { recursive: true });
        }
        
        // Initialize events file if it doesn't exist
        if (!fs.existsSync(this.eventsFile)) {
            fs.writeFileSync(this.eventsFile, '');
        }
    }
    
    publishHookEvent(category, event, data = {}) {
        const eventData = {
            timestamp: new Date().toISOString(),
            instance: this.instanceId,
            category,
            event,
            data,
            session_id: process.env.CC_SESSION_ID || 'unknown'
        };
        
        // Emit locally for any listeners
        this.emit('hook-event', eventData);
        
        // Write to shared event log for other instances
        try {
            fs.appendFileSync(this.eventsFile, JSON.stringify(eventData) + '\n');
        } catch (error) {
            console.error('Failed to write event:', error);
        }
        
        // Send to CKS for knowledge capture
        this.sendToCKS(eventData);
        
        return eventData;
    }
    
    sendToCKS(eventData) {
        // Integration with CKS for knowledge capture
        const { spawn } = require('child_process');
        try {
            const curl = spawn('curl', [
                '-s', '-X', 'POST',
                'http://localhost:5555/events/hook-development',
                '-H', 'Content-Type: application/json',
                '-d', JSON.stringify(eventData)
            ]);
            
            curl.on('error', () => {
                // CKS not available, continue silently
            });
        } catch (error) {
            // Ignore CKS integration errors
        }
    }
    
    getRecentEvents(limit = 10) {
        try {
            const events = fs.readFileSync(this.eventsFile, 'utf8')
                .split('\n')
                .filter(line => line.trim())
                .slice(-limit)
                .map(line => JSON.parse(line));
            return events;
        } catch (error) {
            return [];
        }
    }
    
    subscribeToEvents(callback) {
        this.on('hook-event', callback);
    }
    
    coordinateWithInstance(targetInstance, message, data = {}) {
        return this.publishHookEvent('coordination', 'inter-instance-message', {
            target: targetInstance,
            message,
            data
        });
    }
}

module.exports = HookEventBus;