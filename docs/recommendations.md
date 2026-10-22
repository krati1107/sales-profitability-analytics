# Business Recommendations

Based on the SQL analysis and the Power BI dashboard, here are four actionable recommendations for the executive team.

## 1. Address the Freight Burden in High-Cost Regions
**Finding:** Total freight costs reached 2.25M, representing roughly 17% of total product sales. However, this burden is not evenly distributed. States outside the Southeast (like the North and Northeast) show a disproportionately high freight percentage compared to product price. 
**Recommendation:** Implement localized seller recruitment campaigns in high-freight states. By having sellers physically closer to these customers, cross-state shipping costs and delivery times will decrease, improving margins and customer satisfaction.

## 2. Double Down on High-Performing Categories
**Finding:** The `beleza_saude` (Health & Beauty) and `relogios_presentes` (Watches & Gifts) categories generate the highest sales volume and revenue. 
**Recommendation:** Prioritize marketing spend and platform visibility for these top categories. Additionally, ensure inventory and seller availability is heavily supported during peak seasonal months (e.g., Q4) to capture maximum market share.

## 3. Investigate the September/October Data Drop
**Finding:** The monthly sales trend reveals a sharp, anomalous drop in September and October. 
**Recommendation:** Before adjusting business strategy based on this dip, the Data/Engineering team should audit the raw data ingestion pipeline for these months. This is highly likely a data tracking artifact or a system migration issue, rather than a true drop in customer demand.

## 4. Improve Delivery SLAs to Boost Review Scores
**Finding:** Delivery performance is directly correlated with customer review scores. Late deliveries significantly drag down the average review score.
**Recommendation:** Conduct a deep-dive into the logistics partners handling the highest-late-volume routes. Implementing a more conservative estimated delivery date algorithm during checkout will manage customer expectations better and reduce the negative impact of late arrivals on review scores.
