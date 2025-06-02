def ess_transform(df):
    from numpy import nan
    from pandas import set_option, isnull, to_datetime
    
    df.columns = ['manufacturer','brand','model','battery_technology',
                  'dc_input',
                  'ul_certifying_entity','ul_date','ul_edition',
                  "ul1741_sb_cert","ul1741_sa_test",
                  "ul1741_sa13","ul1741_sa14_sa15",
                  "ul1741_sa17_sa18","csip","attestation",
                  'description','kWh','kW',
                  'volts','kW_max', 
                  'ul1741_sb_cert_entity','ul1741_sb_cert_date',
                  'ul1741_sa_cert_entity','ul1741_sa_cert_date',
                  'ul1741_sa_cert_firmware', 
                  'ul1741_sa_date','ul1741_list_date',
                  'csip_entity','csip_date','attestation_date',
                  'efficiency','control_strategies',
                  'ja12_declaration','notes','date','last_update']

    set_option('future.no_silent_downcasting', True)
    
    for col in [
        'dc_input','ja12_declaration',
        "ul1741_sb_cert","ul1741_sa_test","ul1741_sa13","ul1741_sa14_sa15","ul1741_sa17_sa18","csip","attestation"
    ] :
        df[col] = df[col].replace({'Y':True,'Y*':True,'N':False})
    
    
    df = df.replace({
        nan:None,
        "No Information Submitted":None,
        'Not Applicable':None})

    mask = ~isnull(df.volts)
    df.loc[mask,'volts'] = df.loc[mask,'volts'].astype(int)
    
    df = df[~df[['manufacturer','model']].duplicated(keep='first')].reset_index(drop=True)
    
    cols = ['ul1741_sb_cert_date','ul1741_sa_cert_date','ul1741_sa_date']
    for col in cols:
        df[col] = df[col].replace({'TUV Rheinland':None,'CSA Group':None})
        df[col]=to_datetime(df[col].str.replace("[","").str.replace("]","").str.split(";").str[0],errors="ignore")
        
    for col in [
        'date','last_update','ul_date','ul1741_list_date','csip_date','attestation_date'
    ]:
        df[col] = df[col].replace({
            'TUV Rheinland':None,'CSA Group':None,
            '[':'',']':'',
            '18/12/2023':'2023-12-18',
            "[9/15/2023]":"2023-09-15",
            "[4/1/2025]":"2025-04-01"})

        df[col] = to_datetime(df[col])
    
    ## valid primary key?
    assert(df.duplicated(['manufacturer','model']).any()==False)
    
    return df
