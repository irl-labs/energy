def batteries_transform(df):

    import numpy as np
    
    df.columns = ['manufacturer','brand','model','battery_technology',
                  'description',
                  'ul_certifying_entity','ul_date','ul_edition','kWh','kW',
                  'efficiency','control_strategies',
                  'ja12_declaration','notes','date','last_update']
    df.ja12_declaration = df.ja12_declaration.replace({'Y':True,'N':False})
    df = df.replace({np.nan:None,"No Information Submitted":None})
    
    df = df[~df[['manufacturer','model']].duplicated(keep='first')].reset_index(drop=True)
    #df.date = pd.to_datetime(df.date).replace({pd.NaT:None})
    #df.last_update = pd.to_datetime(df.last_update).replace({pd.NaT:None})
    #df.ul_date = pd.to_datetime(df.ul_date).replace({pd.NaT:None})
    
    ## valid primary key?
    assert(df.duplicated(['manufacturer','model']).any()==False)

    return df
