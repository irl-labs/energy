# --- Inverter Transformation Function ---
def inverters_transform(df):
    """
    Clean and transform the inverter listing DataFrame.
    """
    import numpy as np

    df.columns = [
        'manufacturer', 'model',
        'hybrid_inverter_pv_and_battery', 'ul_1741_SB', 'ul_1741_SA8_SA13',
        'ul_1741_SA13', 'ul_1741_SA14_SA15', 'ul_1741_SA17_SA18',
        'csip', 'attestation', 'description', 'kw', 'volts', 'efficiency',
        'certifying_entity_sb', 'certification_date_sb', 'certifying_entity_sa',
        'certification_date_sa', 'certification_firmware_versions_sa',
        'ul_1741_SA13_date', 'ul_1741_SA_date', 'permit_disable_date',
        'csip_issuing_entity', 'csip_issuing_entity_date', 'attestation_date',
        'notes', 'builtin_meter', 'microinverter', 'night_tare_loss',
        'rated_watts', 'rated_night_tare_loss', 'volts_min', 'volts_nominal', 'volts_max',
        'kw_10', 'kw_20', 'kw_30', 'kw_50', 'kw_75', 'kw_100',
        'efficiency_vmin_10', 'efficiency_vmin_20', 'efficiency_vmin_30',
        'efficiency_vmin_50', 'efficiency_vmin_75', 'efficiency_vmin_100',
        'efficiency_vmin_wtd',
        'efficiency_vnom_10', 'efficiency_vnom_20', 'efficiency_vnom_30',
        'efficiency_vnom_50', 'efficiency_vnom_75', 'efficiency_vnom_100',
        'efficiency_vnom_wtd',
        'efficiency_vmax_10', 'efficiency_vmax_20', 'efficiency_vmax_30',
        'efficiency_vmax_50', 'efficiency_vmax_75', 'efficiency_vmax_100',
        'efficiency_vmax_wtd',
        'grid_date', 'last_update'
    ]

    # Replace NaN, NaT early
    df = df.replace({np.nan: None})
    return df
