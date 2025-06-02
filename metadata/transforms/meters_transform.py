def meters_transform(df):
    from numpy import nan
    from pandas import to_datetime, isnull
    
    df.columns = ['manufacturer','model','meter_display_type','pbi','description','date_on','date_off','meter_id','cec_listing_date','last_update']
    df.drop(['date_on','date_off','meter_id','last_update'],axis=1,inplace=True)
    df.pbi = df.pbi.replace({'Y':True,'N':False})
    df=df.replace({nan:None})
    df = df[~df[['manufacturer','model']].duplicated(keep='first')].reset_index(drop=True)
    df.cec_listing_date = to_datetime(df.cec_listing_date)

    ## valid primary key?
    assert(df.duplicated(['manufacturer','model']).any()==False)
    mask = isnull(df.description)
    df.loc[mask,'description']='No Description'

    return df
