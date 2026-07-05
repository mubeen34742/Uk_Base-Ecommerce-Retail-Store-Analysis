import pandas as pd
import numpy as np


data = pd.read_csv(
    r"C:\Users\creative_demo\Desktop\UK Ecommerce Analyst\data\raw.csv",
    encoding="latin1",
    on_bad_lines="skip"
)


profile = {
    "shape": data.shape,
    "dtypes": data.dtypes,
    "head": data.head()
}

missing_values = data.isnull().sum()
duplicates = data.duplicated().sum()
summary = data.describe(include="all")

print(profile["shape"])
print(profile["dtypes"])
print(profile["head"])

with pd.ExcelWriter("profiling_log.xlsx") as writer:
    missing_values.to_frame("Missing_Count").to_excel(writer, sheet_name="Missing")
    summary.to_excel(writer, sheet_name="Summary")


data["InvoiceDate"] = pd.to_datetime(data["InvoiceDate"])
data["Quantity"] = pd.to_numeric(data["Quantity"], errors="coerce")
data["UnitPrice"] = pd.to_numeric(data["UnitPrice"], errors="coerce")


data = data[data["Quantity"] > 0]        
data = data[data["UnitPrice"] > 0]      

data["CustomerID"] = data["CustomerID"].fillna(
    "GUEST_" + data["InvoiceNo"].astype(str)
)                                  

data["Country"] = data["Country"].replace({
    "EIRE": "Ireland",
    "RSA": "South Africa"
})                                    

data["Description"] = data["Description"].str.strip().str.title()  

data["Revenue"] = data["Quantity"] * data["UnitPrice"]  

data["Year"] = data["InvoiceDate"].dt.year
data["Month"] = data["InvoiceDate"].dt.month
data["DayOfWeek"] = data["InvoiceDate"].dt.day_name()
data["Hour"] = data["InvoiceDate"].dt.hour              


invoice_volume = data.groupby("InvoiceNo")["Quantity"].sum()

data["TotalOrderVolume"] = data["InvoiceNo"].map(invoice_volume)

data["CustomerType"] = np.where(
    data["TotalOrderVolume"] >= 100,
    "B2B",
    "B2C"
)                                                        

data.drop_duplicates(inplace=True)
data.dropna(inplace=True)

data.to_csv("clean_sheet.csv", index=False)