def modules_transform(df):
    from pandas import option_context, isnull

    mask = df.N_p > 1000
    df.loc[mask, 'N_p'] = None

    cols = ['Manufacturer', 'Model Number', 'Description', 'Safety Certification',
            'Nameplate Pmax', 'PTC', 'Notes', 'Design Qualification Certification\n(Optional Submission)',
            'Performance Evaluation (Optional Submission)', 'Family', 'Technology',
            'A_c', 'N_s', 'N_p', 'BIPV', 'Nameplate Isc', 'Nameplate Voc',
            'Nameplate Ipmax', 'Nameplate Vpmax', 'Average NOCT', 'γPmax', 'αIsc',
            'βVoc', 'αIpmax', 'βVpmax', 'IPmax, low', 'VPmax, low', 'IPmax, NOCT',
            'VPmax, NOCT', 'Mounting', 'Type', 'Short Side', 'Long Side',
            'Geometric Multiplier', 'P2/Pref', 'CEC Listing Date', 'Last Update']

    new_cols = ['manufacturer', 'model', 'description', 'safety_certification',
                'watt', 'watt_adjusted', 'ca_notes', 'design_certification',
                'performance_evaluation', 'family', 'ca_module_technology',
                'area', 'cells_series', 'cells_parallel', 'bipv', 'amps', 'volts',
                'amps_pmax', 'volts_pmax', 'noct', 'gamma_pmax', 'alpha_amps',
                'beta_volts', 'alpha_amps_pmax', 'beta_volts_pmax', 'amps_pmax_low', 'volts_pmax_low',
                'amps_pmax_noct', 'volts_pmax_noct', 'ca_module_mounting', 'ca_module_type',
                'length_short_side', 'length_long_side', 'geometric_multiplier', 'p2_perf',
                'listing_date', 'last_update']

    df = df.rename(columns=dict(zip(cols, new_cols))).replace({'No Information Submitted': None})

    for col in ['manufacturer','model']:
        df[col] = df[col].astype(str)
    
    # Fix booleans
    mask = df.bipv == 'Y'
    df.loc[mask, 'bipv'] = True
    mask = df.bipv.isin(['N', 'No'])
    df.loc[mask, 'bipv'] = False

    ## df = df.map(lambda s: s.upper() if isinstance(s, str) else s)

    with option_context('future.no_silent_downcasting', True):
        df.amps_pmax=df.amps_pmax.astype(float)
        df.alpha_amps=df.alpha_amps.astype(float)
        df.alpha_amps_pmax=df.alpha_amps_pmax.replace({'\xa0':None}).astype(float)
        df.beta_volts=df.beta_volts.astype(float)
        df.beta_volts_pmax=df.beta_volts_pmax.replace({'\xa0':None}).astype(float)

    df = df[~df.duplicated(['manufacturer', 'model'])].reset_index(drop=True)
    mask = isnull(df.description)
    df.loc[mask,'description']='No Description'
    
    return df
