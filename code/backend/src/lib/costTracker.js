/**
 * Cost Tracker
 * Monitors LLM API usage and costs across Fable, Minimax, Google Gemini
 * Alerts when approaching budget limits
 */

const fs = require('fs');
const path = require('path');

class CostTracker {
  constructor() {
    this.budgetLimit = parseFloat(process.env.LLM_BUDGET_LIMIT || '1500'); // $1500
    this.warningThreshold = 0.8; // Warn at 80% budget used
    this.logFile = path.join(__dirname, '../../logs/cost_tracking.json');
    this.dailyReportFile = path.join(__dirname, '../../logs/daily_costs.json');

    // Ensure logs directory exists
    const logsDir = path.dirname(this.logFile);
    if (!fs.existsSync(logsDir)) {
      fs.mkdirSync(logsDir, { recursive: true });
    }

    this.initializeLogFile();
  }

  /**
   * Track LLM usage
   */
  async trackUsage({ model, inputTokens, outputTokens, cost }) {
    const usage = {
      timestamp: new Date().toISOString(),
      model,
      inputTokens,
      outputTokens,
      cost,
    };

    // Append to log file
    this._appendToLog(usage);

    // Update daily totals
    this._updateDailyTotals(usage);

    // Check if approaching budget limit
    const totalSpent = this.getTotalSpent();
    const percentUsed = (totalSpent / this.budgetLimit) * 100;

    if (percentUsed >= this.warningThreshold) {
      console.warn(
        `⚠️  LLM Budget Warning: ${percentUsed.toFixed(1)}% of budget used ($${totalSpent.toFixed(2)}/$${this.budgetLimit})`
      );
    }

    if (totalSpent > this.budgetLimit) {
      console.error(
        `🚨 CRITICAL: LLM budget exceeded! Spent $${totalSpent.toFixed(2)}/$${this.budgetLimit}`
      );
    }

    return {
      totalSpent,
      percentUsed,
      remaining: Math.max(0, this.budgetLimit - totalSpent),
    };
  }

  /**
   * Get total spent across all models
   */
  getTotalSpent() {
    try {
      if (!fs.existsSync(this.logFile)) {
        return 0;
      }

      const data = fs.readFileSync(this.logFile, 'utf-8');
      const logs = data
        .split('\n')
        .filter(line => line.trim())
        .map(line => {
          try {
            return JSON.parse(line);
          } catch {
            return null;
          }
        })
        .filter(Boolean);

      return logs.reduce((sum, log) => sum + (log.cost || 0), 0);
    } catch (error) {
      console.error('Error reading cost log:', error);
      return 0;
    }
  }

  /**
   * Get daily cost breakdown
   */
  getDailyCosts() {
    try {
      if (!fs.existsSync(this.dailyReportFile)) {
        return {};
      }

      const data = fs.readFileSync(this.dailyReportFile, 'utf-8');
      return JSON.parse(data || '{}');
    } catch (error) {
      console.error('Error reading daily costs:', error);
      return {};
    }
  }

  /**
   * Get cost summary by model
   */
  getCostsByModel() {
    try {
      if (!fs.existsSync(this.logFile)) {
        return {};
      }

      const data = fs.readFileSync(this.logFile, 'utf-8');
      const logs = data
        .split('\n')
        .filter(line => line.trim())
        .map(line => {
          try {
            return JSON.parse(line);
          } catch {
            return null;
          }
        })
        .filter(Boolean);

      const costsByModel = {};

      logs.forEach(log => {
        const model = log.model || 'unknown';
        if (!costsByModel[model]) {
          costsByModel[model] = { count: 0, totalCost: 0, totalTokens: 0 };
        }
        costsByModel[model].count += 1;
        costsByModel[model].totalCost += log.cost || 0;
        costsByModel[model].totalTokens += (log.inputTokens || 0) + (log.outputTokens || 0);
      });

      return costsByModel;
    } catch (error) {
      console.error('Error calculating costs by model:', error);
      return {};
    }
  }

  /**
   * Get budget status
   */
  getBudgetStatus() {
    const totalSpent = this.getTotalSpent();
    const remaining = this.budgetLimit - totalSpent;
    const percentUsed = (totalSpent / this.budgetLimit) * 100;
    const costsByModel = this.getCostsByModel();

    return {
      budgetLimit: this.budgetLimit,
      totalSpent: parseFloat(totalSpent.toFixed(2)),
      remaining: parseFloat(Math.max(0, remaining).toFixed(2)),
      percentUsed: parseFloat(percentUsed.toFixed(1)),
      costsByModel,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Internal: Append usage to log file
   */
  _appendToLog(usage) {
    try {
      const logEntry = JSON.stringify(usage) + '\n';
      fs.appendFileSync(this.logFile, logEntry);
    } catch (error) {
      console.error('Error appending to cost log:', error);
    }
  }

  /**
   * Internal: Update daily cost totals
   */
  _updateDailyTotals(usage) {
    try {
      const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
      const dailyCosts = this.getDailyCosts();

      if (!dailyCosts[today]) {
        dailyCosts[today] = { count: 0, totalCost: 0 };
      }

      dailyCosts[today].count += 1;
      dailyCosts[today].totalCost += usage.cost || 0;

      fs.writeFileSync(
        this.dailyReportFile,
        JSON.stringify(dailyCosts, null, 2)
      );
    } catch (error) {
      console.error('Error updating daily costs:', error);
    }
  }

  /**
   * Internal: Initialize log file with header
   */
  initializeLogFile() {
    try {
      if (!fs.existsSync(this.logFile)) {
        fs.writeFileSync(
          this.logFile,
          '# StoryForce.AI LLM Cost Tracking Log\n'
        );
      }
    } catch (error) {
      console.error('Error initializing cost log:', error);
    }
  }

  /**
   * Reset daily costs (admin function)
   */
  resetDailyCosts(date) {
    try {
      const dailyCosts = this.getDailyCosts();
      delete dailyCosts[date];
      fs.writeFileSync(
        this.dailyReportFile,
        JSON.stringify(dailyCosts, null, 2)
      );
    } catch (error) {
      console.error('Error resetting daily costs:', error);
    }
  }
}

module.exports = { CostTracker };
