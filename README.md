# Tech Inventory Optimization System
A MySQL-based inventory management system that automates stock optimization, reorder points calculation, and inventory monitoring for tech electronics.

![image](https://github.com/user-attachments/assets/7048276d-f139-4902-a179-aa0c3c957495)

## Technical Implementation
### Database Structure
- `tech_electro` schema
- Tables: sales_data, external_factors, product_information
- Views: inventory_view, sales_product_data

### Core Components
- Stored procedures for inventory monitoring
- Triggers for automated updates
- Safety stock calculations
- Lead time demand analysis
- Stock-out frequency tracking

### Setup & Configuration
1. Create schema
2. Run data cleaning scripts
3. Execute view creation
4. Deploy stored procedures
5. Implement triggers
6. Update database credentials
7. Set safety stock parameters
8. Configure monitoring thresholds
9. Adjust lead time variables

### Documentation
#### Stored Procedures
* `MonitorInventoryLevels()`: Tracks average inventory
* `RecalculateReorderPoint()`: Updates reorder points 
* `MonitorSalesTrend()`: Analyzes sales patterns
* `MonitorStockouts()`: Tracks stockout frequency

#### Views
* `inventory_view`: Integrated view of sales and external factors
* `sales_product_data`: Combined sales and product information

## General Insights
Inventory Discrepancies: The initial stages of the analysis revealed significant discrepancies in inventory levels, with instances of both overstocking and understocking. These inconsistencies were contributing to capital inefficiencies and customer dissatisfaction.

Sales Trends and External Influences: The analysis indicated that sales trends were notably influenced by various external factors. Recognizing these patterns provides an opportunity to forecast demand more accurately.

Suboptimal Inventory Levels: Through the inventory optimization analysis, it was evident that the existing inventory levels were not optimized for current sales trends. Products was identified that had either close excess inventory.

## Feedback Loop System
### Feedback Loop Establishment
- Feedback Portal: Develop an online platform for stakeholders to easily submit feedback on inventory performance and challenges.
- Review Meetings: Organize periodic sessions to discuss inventory system performance and gather direct insights.
- System Monitoring: Use established SQL procedures to track system metrics, with deviations from expectations flagged for review.

### Refinement Based on Feedback
- Feedback Analysis: Regularly compile and scrutinize feedback to identify recurring themes or pressing issues.
- Action Implementation: Prioritize and act on the feedback to adjust reorder points, safety stock levels, or overall processes.
- Change Communication: Inform stakeholders about changes, underscoring the value of their feedback and ensuring transparency.

## Recommendations
1. Implement Dynamic Inventory Management: The company should transition from a static to a dynamic inventory management system, adjusting inventory levels based on real-time sales trends, seasonality, and external factors.

2. Optimize Reorder Points and Safety Stocks: Utilize the reorder points and safety stocks calculated during the analysis to minimize stockouts and reduce excess inventory. Regularly review these metrics to ensure they align with current market conditions.

3. Enhance Pricing Strategies: Conduct a thorough review of product pricing strategies, especially for products identified as unprofitable. Consider factors such as competitor pricing, market demand, and product acquisition costs.

4. Reduce Overstock: Identify products that are consistently overstocked and take steps to reduce their inventory levels. This could include promotional sales, discounts, or even discontinuing products with low sales performance.

5. Establish a Feedback Loop: Develop a systematic approach to collect and analyze feedback from various stakeholders. Use this feedback for continuous improvement and alignment with business objectives.

6. Regular Monitoring and Adjustments: Adopt a proactive approach to inventory management by regularly monitoring key metrics and making necessary adjustments to inventory levels, order quantities, and safety stocks.

## Tech Stack
- MySQL 8.0
- SQL procedures and triggers
- Views and CTEs
- Database optimization techniques

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Push to branch
5. Submit pull request

## Support
* Submit issues via GitHub
* Contact: eneojaide@gmail.com

## License
MIT License
