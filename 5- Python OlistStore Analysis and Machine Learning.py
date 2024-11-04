# Import necessary libraries
import pyodbc
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, silhouette_score

# MSSQL Connection Setup using Windows Authentication
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=IT-NB-040\MSSQLSERVERR;'
    'DATABASE=Olist_Warehouse_2;'
    'Trusted_Connection=yes;'
)

# 1. Load Data from MSSQL Tables into Pandas DataFrames
dim_customers = pd.read_sql("SELECT * FROM Dim_Customers", conn)
dim_orders = pd.read_sql("SELECT * FROM Dim_Orders", conn)
dim_products = pd.read_sql("SELECT * FROM Dim_Products", conn)
dim_sellers = pd.read_sql("SELECT * FROM Dim_Sellers", conn)
fact_order_items = pd.read_sql("SELECT * FROM Fact_OrderItems", conn)

# 2. Exploratory Data Analysis (EDA)
# 2.1. Customer Distribution by State
plt.figure(figsize=(10,6))
sns.countplot(y='customer_state', data=dim_customers, order=dim_customers['customer_state'].value_counts().index)
plt.title('Customer Distribution by State')
plt.show()

# 2.2. Orders by Status
plt.figure(figsize=(10,6))
sns.countplot(x='order_status', data=dim_orders)
plt.title('Orders by Status')
plt.xticks(rotation=45)
plt.show()

# 2.3. Descriptive Statistics for Customers and Orders
print("Dim_Customers Description:\n", dim_customers.describe())
print("Dim_Orders Description:\n", dim_orders.describe())

# 3. Feature Engineering
# 3.1. Calculate delivery time (difference between order purchase and delivery date)
dim_orders['delivery_time'] = (pd.to_datetime(dim_orders['order_delivered_customer_date']) - 
                               pd.to_datetime(dim_orders['order_purchase_timestamp'])).dt.days

# 3.2. Customer Lifetime Value (sum of all order values per customer)
customer_lifetime_value = fact_order_items.groupby('customer_id')['price'].sum().reset_index()
customer_lifetime_value.columns = ['customer_id', 'lifetime_value']

# Merge with customers DataFrame
dim_customers = pd.merge(dim_customers, customer_lifetime_value, on='customer_id', how='left')

# 4. Machine Learning

# 4.1. Customer Segmentation using KMeans
# Prepare data for clustering
customer_features = dim_customers[['customer_zip_code_prefix', 'lifetime_value']].dropna()

# Perform KMeans clustering
kmeans = KMeans(n_clusters=3, random_state=42)
dim_customers['customer_cluster'] = kmeans.fit_predict(customer_features)

# Silhouette score to evaluate clustering
silhouette_avg = silhouette_score(customer_features, dim_customers['customer_cluster'])
print(f"Silhouette Score for Customer Clusters: {silhouette_avg}")

# 4.2. Predicting Delivery Delays using Random Forest
# Define features and target for delay prediction
dim_orders['is_delayed'] = (dim_orders['order_delivered_customer_date'] > 
                            dim_orders['order_estimated_delivery_date']).astype(int)

# Features for model
features = dim_orders[['order_status', 'order_estimated_delivery_date', 'order_purchase_timestamp']]
target = dim_orders['is_delayed']

# Convert categorical features to numerical
features = pd.get_dummies(features, columns=['order_status'], drop_first=True)

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.3, random_state=42)

# Train Random Forest Classifier
rf = RandomForestClassifier(n_estimators=100, random_state=42)
rf.fit(X_train, y_train)

# Predict and evaluate
y_pred = rf.predict(X_test)
print("Classification Report:\n", classification_report(y_test, y_pred))

# 5. Visualization of Clusters and Feature Importance

# Visualizing customer clusters
plt.figure(figsize=(10,6))
sns.scatterplot(x='lifetime_value', y='customer_zip_code_prefix', hue='customer_cluster', data=dim_customers)
plt.title('Customer Clusters based on Lifetime Value and Zip Code')
plt.show()

# Feature Importance for Delivery Delay Prediction
importances = rf.feature_importances_
feature_names = X_train.columns

# Plot Feature Importance
plt.figure(figsize=(10,6))
plt.barh(feature_names, importances)
plt.title('Feature Importance for Delivery Delay Prediction')
plt.show()

# 6. Closing the connection to MSSQL
conn.close()
