import pandas as pd
import numpy as np
import streamlit as st 
from sklearn.linear_model import LogisticRegression
from pickle import dump
from pickle import load
import pickle
from sklearn.preprocessing import MinMaxScaler
from sklearn import preprocessing


data=pd.read_csv("Churn.csv")
data=pd.get_dummies(data,columns=['area.code'],drop_first=True)
data['churn']=data.churn.replace({'yes':1,'no':0})
data['voice.plan']=data['voice.plan'].replace({'yes':1,'no':0})
data['intl.plan']=data['intl.plan'].replace({'yes':1,'no':0})
data.drop(['Unnamed: 0','state'],axis=1,inplace=True)
array = data.values
x = array[:, 0:-1]
scaler = MinMaxScaler()
scaler.fit(x)
loaded_model = load(open('Chrun_RF.sav', 'rb'))

def churn_prediction(input_data):
    

    # changing the input_data to numpy array
    input_data_as_numpy_array = np.asarray(input_data)

    # reshape the array as we are predicting for one instance
    input_data_reshaped = input_data_as_numpy_array.reshape(1,-1)
    
    input_data_reshaped=scaler.transform(input_data_reshaped)
    prediction = loaded_model.predict(input_data_reshaped)
    print(prediction)

    if (prediction[0] == 1):
      return 'Positive '
    else:
      return 'Negative '


def main():
    
    # giving a title
    st.title("Telecommunication Customer Churn")
    # getting the input data from the user
    area_code = st.number_input('Area Code')
    account_length = st.number_input('Account Length')
    voice_plan = st.number_input('Voice Plan')
    voice_messages = st.number_input('Voice Messages')
    intl_plan = st.number_input('International Plan')
    intl_mins = st.number_input('International Minutes')
    intl_calls = st.number_input('International Calls')
    intl_charge = st.number_input('International Charge')
    day_mins = st.number_input('Day Minutes')
    day_calls = st.number_input('Day Calls')
    day_charge = st.number_input('Day Charge')
    eve_mins = st.number_input('Evening Minutes')
    eve_calls = st.number_input('Evening Calls')
    eve_charge = st.number_input('Evening Charge')
    night_mins = st.number_input('Night Minutes')
    night_calls = st.number_input('Night Calls')
    night_charge = st.number_input('Night Charge')
    customer_calls = st.number_input('Customer Calls')

    
    # code for Prediction
    churn_output = ''
    
    # creating a button for Prediction
    
    if st.button('Prediction'):
        churn_output = churn_prediction([area_code, account_length, voice_plan, voice_messages, intl_plan, intl_mins, intl_calls, intl_charge, day_mins, day_calls, day_charge, eve_mins, eve_calls, eve_charge, night_mins, night_calls, night_charge, customer_calls])    
        
        
    st.success(churn_output)
    
    
if __name__ == '__main__':
    main()
    


