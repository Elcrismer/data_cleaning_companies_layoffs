import pandas as pd
file_path =r"C:\Users\elkin\Downloads\archive (1)\train.csv"
df = pd.read_csv(file_path)
#print(df.head())
#print(df.info())
#convert to datetime
df['Order Date'] = pd.to_datetime(df['Order Date'], dayfirst=True, errors='coerce', format='mixed')
df['Ship Date'] = pd.to_datetime(df['Ship Date'], dayfirst=True, errors='coerce', format='mixed')
# Verificar la conversión
#(df[['Order Date']].head())
#print(df[['Ship Date']].head())
#(df.describe())
#verificar si hay valores nulos
print(df.isnull().sum())
#reemplazar valores nulos con ceros
df_filled_zero = df.fillna(0)
#print(df_filled_zero.isnull().sum())
#print("Rango de fechas:", df['Order Date'].min(), "→", df['Order Date'].max())
df['Year'] = df['Order Date'].dt.year
df['Month'] = df['Order Date'].dt.to_period('M')
import matplotlib.pyplot as plt
sales_by_month = df.groupby('Month')['Sales'].sum()
sales_by_month.plot(kind='line', figsize=(12,6), title='Ventas Mensuales')
plt.show()
