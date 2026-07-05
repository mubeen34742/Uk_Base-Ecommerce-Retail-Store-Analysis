import pandas as pd 
import numpy as np 

data = pd.read_csv(r"C:\Users\creative_demo\Desktop\UK Ecommerce Analyst\data.csv\raw.csv")
print(data.shape)
print(data.dtype)
print(data.columns())
