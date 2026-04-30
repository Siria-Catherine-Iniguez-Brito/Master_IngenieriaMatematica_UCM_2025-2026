
# Práctica - Ana Marta Oliveira y Siria Catherine Íñiguez

#Imports
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import scipy.optimize as sco
from IPython.display import display

# Función para unificar el estilo de las tablas sacadas por el html
def aplicar_estilo(styler, titulo):
    return styler.set_caption(titulo)\
        .set_table_styles([
            # Título
            {'selector': 'caption', 'props': [
                ('color', '#1a2a6c'), ('font-size', '17px'), ('font-weight', 'bold'),
                ('text-align', 'left'), ('padding', '15px 0px 10px 0px')]},

            # Cabeceras (Nombres de Activos)
            {'selector': 'th:not(.index_name)', 'props': [
                ('background-color', '#1a2a6c'), ('color', '#ffffff'),
                ('font-size', '12px'), ('padding', '12px'),
                ('border', '1px solid #d1d8e0')]},

            # Celdas de Datos
            {'selector': 'td', 'props': [
                ('font-size', '12px'), ('padding', '10px 15px'),
                ('border', '1px solid #d1d8e0')]},

            # El índice (Las Fechas)
            {'selector': 'th.row_heading', 'props': [
                ('background-color', '#1a2a6c'), ('color', '#ffffff'),
                ('font-size', '11px'), ('padding', '10px'),
                ('border', '1px solid #d1d8e0')]},

            # Borde exterior de la tabla
            {'selector': '', 'props': [('border', '2px solid #1a2a6c')]}
        ])\
        .set_properties(**{'text-align': 'center'})
PALETA = {
    'cabecera_bg': '#1a2a6c',     
    'cabecera_txt': '#ffffff',    
    'borde_fino': '#d1d8e0',      
    'positivo': '#2d8a4e',
    'negativo': '#a93226'
}


# %% -------------------------------------------------------------------------
# Data loading
df = pd.read_csv('monthly_prices.csv')
# Convert index to datetime type if needed
if isinstance(df.index, pd.DatetimeIndex)==False:
    df['Date'] = pd.to_datetime(df['Date'])
    df = df.set_index('Date')

print(f"\n --- FASE 1: CARGA ---")
print(f"Activos iniciales: {df.shape[1]}")
print(f"Observaciones temporales iniciales: {df.shape[0]} \n\n")

df_t1 = df.iloc[:5, :5].copy()
df_t1.columns.name = None  # Eliminamos el nombre de las columnas
df_t1.index.name = None    # Eliminamos el nombre del índice para evitar el salto

t1 = aplicar_estilo(df_t1.style, "01. MATRIZ DE PRECIOS ORIGINAL ").format("{:.2f}")



# %% -------------------------------------------------------------------------
# Clean and Validate the Dataset

# Only assets with all prices > 0
df_raw = df.copy()
df = df.loc[:, (df> 0).all()]

# Remove columns with all prices repeated
column_to_drop = df.columns[df.nunique() == 1]
df = df.drop(column_to_drop, axis=1)

# log returns df, and first row (nan's) removing
log_returns_df = np.log(df/df.shift(1))
log_returns_df = log_returns_df.drop(df.index[0])

print(f"\n--- FASE 2: LIMPIEZA ---")
print(f"Activos tras limpiar ceros/constantes: {log_returns_df.shape[1]}")
print(f"Filas de rentabilidades (debe ser N-1): {log_returns_df.shape[0]}")


df_t2 = log_returns_df.iloc[:5, :5].copy()
df_t2.columns.name = None
df_t2.index.name = None

t2 = aplicar_estilo(df_t2.style, "02. RENTABILIDADES LOGARÍTMICAS")\
    .format("{:.2%}")\
    .map(lambda x: f'color: {PALETA["negativo"]}; font-weight: bold' if x < 0 else f'color: {PALETA["positivo"]}; font-weight: bold')



#  %% -------------------------------------------------------------------------
# Narrow the Investment Universe

# Only assets with possitive expected return
log_returns = log_returns_df.to_numpy()
exp_returns = log_returns.mean(axis=0)
log_returns_df = log_returns_df.loc[:, exp_returns > 0]
print(f"\n--- FASE 3: FILTRO RENDIMIENTO ---")
print(f"Activos con retorno medio positivo: {log_returns_df.shape[1]}")

# Numpy arrays variables
log_returns = log_returns_df.to_numpy()
exp_returns = log_returns.mean(axis=0)
corr_matrix = np.corrcoef(log_returns, rowvar=False)
vol = log_returns.std(axis=0, ddof=1)

# Avg. correlation, and risk vs. return criteria
num_assets = len(exp_returns)
avg_corr = (num_assets*corr_matrix.mean(axis=0) - 1) / (num_assets- 1)
asset_features = np.array([range(num_assets), log_returns_df.columns.tolist(),
                        exp_returns/vol, avg_corr])

# Get the indices to sort the avg. correlation row in descending order
# Statement np.argsort(asset_features[3]) to obtain the indices
# that would sort the row of asset_features in ascending order.
# Then [::-1] slicing notation reverses the order of the sorted indices,
# effectively sorting the avg. correlation row in descending order.

# Sort the asset_features by the risk vs. return in descending order
asset_sort_rnr = asset_features[:, np.argsort(asset_features[2])[::-1]]
# Sort the asset_features based on the avg. correlation in ascending order
asset_sort_corr = asset_features[:, np.argsort(asset_features[3])]

# Only n assets with nice features
n_selected_assets = 20
selected_assets = np.concatenate((asset_sort_rnr[0:2,0:20],
                                 asset_sort_corr[0:2,0:20]),
                                 axis=1)
# Remove repeated columns
selected_assets = np.unique(selected_assets, axis=1)
log_returns_df = log_returns_df.iloc[:, selected_assets[0,:].astype(int)]

# Selected assets log-returns and tickers
returns = log_returns_df.to_numpy()
tickers = selected_assets[1,:].tolist()

print(f"\n--- FASE 4: UNIVERSO SELECCIONADO ---")
print(f"¿Cumple el mínimo de 30 activos?: {'SÍ' if len(tickers) >= 30 else 'NO'}")
print(f"Total de activos seleccionados: {len(tickers)}")
print(f"Nombres de los primeros 10 activos: {tickers[:10]}")

# Covariance and correlation matrices.
# 'rowvar=False' indicates that each column represents a variable (i.e., an asset),
# while each row represents an observation (i.e., a time point).
# 'bias=False' indicates that the normalization is by (T-1), where T is the number
# of observations, providing an unbiased estimate.
covariance_matrix = np.cov(returns, rowvar=False, bias=False)
corr_matrix = np.corrcoef(returns, rowvar=False)
# Expected returns vector
expected_return = returns.mean(axis=0)

final_stats = pd.DataFrame({
    'Ticker': tickers,
    'Retorno Medio': expected_return,
    'Volatilidad': np.sqrt(np.diag(covariance_matrix))
}).set_index('Ticker').head(15)
final_stats['Ratio Eficiencia'] = final_stats['Retorno Medio'] / final_stats['Volatilidad']

df_t3 = final_stats.copy()
df_t3.index.name = None  
df_t3.columns.name = None 
t3 = aplicar_estilo(df_t3.style, "03. MÉTRICAS CLAVE: Parámetros de Optimización (Top 15)")\
    .format({
        'Retorno Medio': "{:.2%}", 
        'Volatilidad': "{:.2%}", 
        'Ratio Eficiencia': "{:.2f}"
    })\
    .background_gradient(
        cmap='Blues', 
        subset=['Ratio Eficiencia'], 
        low=0, high=0.5  
    )


#  %% -------------------------------------------------------------------------
# Check if all eigenvalues are positive
eigenvalues, eigenvectors = np.linalg.eigh(covariance_matrix)
if np.all(eigenvalues > 0) == False:
    eps = 1.e-11
    eigenvalues[eigenvalues < 0] = eps
    # nearest positive definite matrix in terms of the Frobenius norm.
    pos_def_covar_matrix = eigenvectors @ np.diag(eigenvalues) @ eigenvectors.T
    # using the Singular Value Decomposition (SVD)
    U, S, V = np.linalg.svd(covariance_matrix)
    S[S < 0] = eps
    pos_def_covar_matrix_svd = U @ np.diag(S) @ V
    print('Covariance matrix was not positive definite. ' \
    'Adjusted using eigenvalue correction.')
else:
    print('Covariance matrix is positive definite.')

print(f"\n--- FASE 5: MATRIZ DE COVARIANZA ---")
if np.all(eigenvalues > 0):
    print("La matriz es Definida Positiva (Lista para optimizar).")
else:
    print("La matriz necesitó corrección de autovalores.")

# %% ------------------------------------------------------------------------------------
# Portfolio metrics and optimization routines
def portfolio_risk_return(weights, returns):
    ''' Returns portfolio risk (volatility) and (expected) return.
    Parameters
    ==========
    weights := array containing the weights for the different securities in the portfolio,
    returns := array-like securities returns in each column.
    
    Output
    =======
    prisk   := float portfolio standard deviation (i.e., volatility),
    preturn := float expected portfolio return.
    '''
    # Covariance matrix and expected return estimations
    covar_matrix = np.cov(returns, rowvar=False, bias=False)
    expected_return = np.mean(returns, axis=0) # securities in columns
    # Output calculation
    weights = np.array(weights)
    prisk = np.sqrt(np.dot(weights.T, np.dot(covar_matrix , weights)))
    preturn = np.sum(expected_return * weights)
    return np.array([prisk, preturn])

def min_risk_portfolio(returns, target_return = None, min_weight = 0., 
                       max_weight = 1., debug = False):
    ''' Minimum volatility portfolio weights computation.
    Parameters
    ==========
    returns := array-like securities returns in each column.
    
    Optional parameters
    ==========
    target_return := float target portfolio expected return (default value = 'None'),
    min_weight    := float minimum weight allowed for each security (default value = 0),
    max_weight    := float maximum weight allowed for each security (default value = 1),
    debug         := boolean to enable/disable debug information (default value = False).
    
    Output
    =======
    weigths : array with the different securities weights in the portfolio
    ''' 
    # Goal function to be minimized.
    def portfolio_variance(weights):
        return portfolio_risk_return(weights, returns)[0] ** 2
    # Goal function to be minimized.
    def portfolio_expected_return(weights):
        return portfolio_risk_return(weights, returns)[1]
    # Returns data dimensions.
    num_rows, num_secs = returns.shape
    # Initial seed.
    weights_seed = num_secs * [1. / num_secs]
    # Constraints (in canonical form)
    if target_return == None:
        cons = ({'type': 'eq', 'fun': lambda x: np.sum(x) - 1})
    else:
        cons = ({'type': 'eq', 'fun': lambda x: np.sum(x) - 1},
                {'type': 'eq', 'fun': lambda x: portfolio_expected_return(x) 
                 - target_return})
    # Weights bounds
    bnds = tuple((min_weight, max_weight) for _ in range(num_secs))
    optr = sco.minimize(portfolio_variance, weights_seed, method='SLSQP', 
                        bounds=bnds, constraints=cons)
    if debug: print(optr)
    return optr['x']

def max_sharpe_portfolio(returns, risk_free_rate = 0., min_weight = None, 
                         max_weight = None, debug = False):
    ''' Maximum Sharpe ratio portfolio weights computation.
    Parameters
    ==========
    returns := array-like securities retuns in each column
    
    Optional parameters
    ==========
    risk_free_rate:= float reference risk free rate (default value = 0),
    min_weight    := float minimum weight allowed for each security (def. value = None),
    max_weight    := float maximum weight allowed for each security (def. value = None),
    debug         := boolean to enable/disable debug information (def. value = False).
    
    Output
    =======
    weigths : array with the different securities weights in the portfolio.
    ''' 
    # Goal function to be minimized: - Sharpe Ratio.
    def portfolio_negative_sharpe_ratio(weights):
        mu_hat = portfolio_risk_return(weights, returns)[1] - risk_free_rate
        sigma = portfolio_risk_return(weights, returns)[0] 
        return - mu_hat / sigma
    # Number of securities
    num_secs = returns.shape[1]
    
    # Optimization algorithm's call (with or without bounds)
    if max_weight is not None and min_weight is not None: # check both are provided
        # Initial guess (equal weights)
        weights_seed = num_secs * [1. / num_secs,]
        # budget constraint
        cons = ({'type': 'eq', 'fun': lambda x: np.sum(x) - 1})
        # weights bounds
        bnds = tuple((min_weight, max_weight) for _ in range(num_secs))
        # Optimization call with bounds and budget constraint 
        optr = sco.minimize(portfolio_negative_sharpe_ratio, weights_seed, 
                            method='SLSQP', bounds=bnds, constraints=cons)
        if debug: print(optr)
        max_sharpe_weights = optr['x']
    else: # closed-form solution (budget-only constraint)
        # Expected returns excess and covariance matrix estimation 
        mu_hat = returns.mean(axis=0) - risk_free_rate
        covariance_matrix = np.cov(returns, rowvar=False, bias=False)
        # M column vector creation
        M = np.zeros( (num_secs, 1) )
        M[:,0] = mu_hat
        # Omega creation
        Omega = np.zeros( (num_secs + 1, num_secs + 1 ) )
        Omega[0:-1,0:-1] = covariance_matrix
        Omega[0:-1,-1:] = M
        Omega[-1:,0:-1] = np.transpose(M)
        # B vector creation
        B = np.zeros( (num_secs + 1, 1) )
        B[-1] = 1.
        # Weights and multipliers computation
        try: # attempt to solve the linear system exactly
            sol = np.linalg.solve(Omega, B)
            # 'np.linalg.solve(Omega, B)' requires that Omega is square 
            # (number of rows equals number of columns) and non-singular 
            # (invertible, i.e., determinant ≠ 0). If successful, it returns 
            # the exact solution 'sol'. If Omega is singular (not invertible, 
            # e.g., determinant = 0) or there is some other numerical issue, 
            # 'np.linalg.solve' raises a 'LinAlgError'.
        except np.linalg.LinAlgError:
            # Fall back to least squares if singular (can occur in practice due 
            # to redundant constraints or collinear variables.)
            sol, *_ = np.linalg.lstsq(Omega, B, rcond=None)
            # 'np.linalg.lstsq(Omega, B, rcond=None)' computes the least-squares 
            # solution to the equation 'Omega * x = B'. It finds an 'x' that 
            # minimizes the Euclidean 2-norm ||Omega * x - B||. This method is 
            # particularly useful when 'Omega' is singular or not square, as it
            # provides a best-fit solution in the least-squares sense. 
            # The algorithm uses Singular Value Decomposition (SVD). Singular values 
            # smaller than rcond * largest_singular_value are treated as zero—ignored 
            # for stability. This helps avoid numerical errors from nearly singular or 
            # ill-conditioned matrices. 
            # 'rcond=None' is safe for most cases, especially if the best threshold is 
            # not known for the given data. It can be set rcond to a small value (e.g., 
            # 1e-15) for more control, but None is usually fine.
        # Extract weights from solution
        w = sol[:num_secs]
        # Enforce exact budget normalization (robust to numerical noise)
        w = w / np.sum(w)
        # Return weights as 1D array
        max_sharpe_weights = np.asarray(w, dtype=float).reshape(-1)
        # 'np.asarray(w, dtype=float)' converts the input 'w' (which can be a 
        # list, tuple, or other array-like object) into a NumPy array of type float.
        # If 'w' is already a NumPy array, this is a no-op except for ensuring the 
        # dtype is float. 
        # '.reshape(-1)' ''flattens'' the array into a 1-dimensional array. 
        # The '-1' argument tells NumPy to infer the size of the dimension automatically, 
        # so all elements are put into a single row (if 2D) or a single column (if 
        # column vector).
    
    return max_sharpe_weights

#  %% -------------------------------------------------------------------------
# Efficient Frontier Construction

# --- CONFIGURACIÓN DEL ESCENARIO I ---
# Sin restricciones significa que min_weight y max_weight son None (o muy grandes)
# En este caso, para permitir Short Selling absoluto, usamos límites amplios:
min_w, max_w = -10, 10 

# 1. Definir el rango de retornos objetivo para la frontera
# Vamos desde el retorno del activo con menor retorno hasta el máximo (o un poco más)
target_returns = np.linspace(expected_return.min(), expected_return.max() * 1.5, 50)

# 2. Calcular la volatilidad mínima para cada retorno objetivo
eff_frontier_risk = []
for tr in target_returns:
    # Llamamos a la función del profesor permitiendo pesos negativos
    w_opt = min_risk_portfolio(returns, target_return=tr, min_weight=min_w, max_weight=max_w)
    risk = portfolio_risk_return(w_opt, returns)[0]
    eff_frontier_risk.append(risk)

# 3. Calcular carteras notables para la gráfica
# Cartera de Mínima Varianza Global (GMV)
w_gmv = min_risk_portfolio(returns, target_return=None, min_weight=min_w, max_weight=max_w)
risk_gmv, ret_gmv = portfolio_risk_return(w_gmv, returns)

# Cartera Tangente (Max Sharpe) - Escenario sin risk-free por ahora
w_ms = max_sharpe_portfolio(returns, min_weight=min_w, max_weight=max_w)
risk_ms, ret_ms = portfolio_risk_return(w_ms, returns)


# Grafica
sel_vols = np.sqrt(np.diag(covariance_matrix))
sel_rets = expected_return

# Paleta de colores
PALETA_AESTHETIC = {
    'cabecera': '#1a2a6c', 'activos': '#4b7bef',
    'gmv': '#2c3e50', 'sharpe': '#d4af37',
    'borde_rejilla': '#d1d8e0', 'fondo_leyenda': '#fdfdfd'
}

# Configuración de la figura
plt.figure(figsize=(8, 6), facecolor='white') 
ax = plt.gca()

# Activos seleccionados
plt.scatter(sel_vols, sel_rets, color=PALETA_AESTHETIC['activos'],alpha=0.7, s=85, edgecolor='white', linewidth=0.8,label='Activos Seleccionados (n=40)',zorder=2)

# Frontera eficiente
plt.plot(eff_frontier_risk, target_returns, color=PALETA_AESTHETIC['cabecera'], linewidth=3.2, label='Frontera Eficiente (Unconstrained)',zorder=3)

# Carteras clave

# Cartera GMV: Estrella Azul
plt.scatter(risk_gmv, ret_gmv, color=PALETA_AESTHETIC['gmv'], marker='*', s=500, alpha=0.1, zorder=4)
plt.scatter(risk_gmv, ret_gmv, color=PALETA_AESTHETIC['gmv'], marker='*', s=250, edgecolor='white', linewidth=1, label='Cartera GMV', zorder=5)

# Cartera Max Sharpe: Círculo Dorado
plt.scatter(risk_ms, ret_ms, color=PALETA_AESTHETIC['sharpe'], marker='o', s=400, alpha=0.15, zorder=4)
plt.scatter(risk_ms, ret_ms, color=PALETA_AESTHETIC['sharpe'], marker='o', s=150, edgecolor='white', linewidth=1.5, label='Max Sharpe', zorder=5)

# Formato y estilo 
plt.title('ESCENARIO I: OPTIMIZACIÓN DE CARTERA (UNCONSTRAINED)', fontsize=14, fontweight='bold', color=PALETA_AESTHETIC['cabecera'], pad=25)

ax = plt.gca()
ax.xaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.yaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.xaxis.set_major_locator(mtick.MaxNLocator(nbins=10)) 

# Limitamos el zoom a la zona donde está la frontera y la mayoría de activos.
vol_corte = min(max(sel_vols), 0.40) # Limitamos la vista a un máximo del 40% de vol si hay outliers
plt.xlim(0, vol_corte)
plt.ylim(min(sel_rets) - 0.005, max(sel_rets) + 0.01)

plt.xlabel(r'Volatilidad Mensual ($\sigma$)', fontsize=11, fontweight='bold', color='#2d3436')
plt.ylabel(r'Retorno Mensual Esperado ($\mu$)', fontsize=11, fontweight='bold', color='#2d3436')

plt.grid(True, linestyle=':', color=PALETA_AESTHETIC['borde_rejilla'], alpha=0.8, zorder=0)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.legend(fontsize=9, loc='best', frameon=True, facecolor=PALETA_AESTHETIC['fondo_leyenda'], edgecolor=PALETA_AESTHETIC['borde_rejilla'], shadow=True)
plt.tight_layout()
plt.show()


# --- CONFIGURACIÓN DEL ESCENARIO II (LONG-ONLY) ---
# Restricción: No se permiten ventas en corto (pesos entre 0 y 1)
min_w_ii, max_w_ii = 0.0, 1.0 

# 1. Carteras Notables (Calculadas primero para definir el corte)
# GMV Long-Only (Punto de mínima varianza absoluto)
w_gmv_ii = min_risk_portfolio(returns, target_return=None, min_weight=min_w_ii, max_weight=max_w_ii)
risk_gmv_ii, ret_gmv_ii = portfolio_risk_return(w_gmv_ii, returns)

# Max Sharpe Long-Only (Punto de máxima eficiencia)
w_ms_ii = max_sharpe_portfolio(returns, min_weight=min_w_ii, max_weight=max_w_ii)
risk_ms_ii, ret_ms_ii = portfolio_risk_return(w_ms_ii, returns)

# 2. Definir el rango de retornos objetivo (desde el mínimo del mercado hasta el máximo)
target_returns_ii = np.linspace(expected_return.min(), expected_return.max(), 100)

# 3. Bucle de Optimización para la Frontera
eff_frontier_risk_ii = []
for tr in target_returns_ii:
    w_opt = min_risk_portfolio(returns, target_return=tr, min_weight=min_w_ii, max_weight=max_w_ii)
    risk = portfolio_risk_return(w_opt, returns)[0]
    eff_frontier_risk_ii.append(risk)

# Convertimos a arrays para aplicar la máscara de eficiencia
rets_array = np.array(target_returns_ii)
risks_array = np.array(eff_frontier_risk_ii)
mask_eficiente = rets_array >= ret_gmv_ii  # Solo lo que rinde más o igual que la GMV

# 4. Gráficas
plt.figure(figsize=(10, 7), facecolor='white')
ax = plt.gca()

# Dibujo de Activos Individuales 
plt.scatter(sel_vols, expected_return, color=PALETA_AESTHETIC['activos'], alpha=0.3, s=70, edgecolor='white', label='Activos individuales', zorder=2)

# Rama ineficiente: Conecta el retorno mínimo con la GMV
plt.plot(risks_array[~mask_eficiente], rets_array[~mask_eficiente], color='#d1d8e0', linestyle='--', linewidth=2, label='Tramo Ineficiente (Inf. a GMV)', zorder=3)

# Frontera eficiente: Desde la GMV hacia arriba
plt.plot(risks_array[mask_eficiente], rets_array[mask_eficiente],color=PALETA_AESTHETIC['cabecera'], linewidth=3.5, label='Frontera Eficiente (Long-Only)', zorder=4)

# Cartera GMV (Mínima Varianza)
plt.scatter(risk_gmv_ii, ret_gmv_ii, color=PALETA_AESTHETIC['gmv'], marker='*', s=350, edgecolor='white', linewidth=1.2, label='Cartera GMV', zorder=5)

# Cartera Max Sharpe (Máxima Eficiencia)
plt.scatter(risk_ms_ii, ret_ms_ii, color=PALETA_AESTHETIC['sharpe'], marker='o', s=180, edgecolor='white', linewidth=1.5, label='Máx. Sharpe (Tangente)', zorder=6)

vol_max_grafica = min(max(sel_vols) * 1.1, 0.40) 
plt.xlim(0, vol_max_grafica)
plt.ylim(expected_return.min() - 0.005, expected_return.max() * 1.2)
plt.title('ESCENARIO II: OPTIMIZACIÓN LONG-ONLY\n', fontsize=13, fontweight='bold', color=PALETA_AESTHETIC['cabecera'], pad=20)

# Formateadores de porcentaje
ax.xaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.yaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.xaxis.set_major_locator(mtick.MultipleLocator(0.05))

plt.xlabel(r'Volatilidad Mensual ($\sigma$)', fontweight='bold', fontsize=10)
plt.ylabel(r'Retorno Mensual Esperado ($\mu$)', fontweight='bold', fontsize=10)

plt.grid(True, linestyle=':', color=PALETA_AESTHETIC['borde_rejilla'], alpha=0.6)
plt.legend(fontsize=9, loc='upper left', frameon=True, shadow=True)
plt.tight_layout()
plt.show()


# --- CONFIGURACIÓN DEL ESCENARIO III (BOUNDED WEIGHTS) ---
# Restricción: Pesos entre 0 y 5%
min_w_iii, max_w_iii = 0.0, 0.05 

# 1. Carteras Notables Escenario III
w_gmv_iii = min_risk_portfolio(returns, target_return=None, min_weight=min_w_iii, max_weight=max_w_iii)
risk_gmv_iii, ret_gmv_iii = portfolio_risk_return(w_gmv_iii, returns)

w_ms_iii = max_sharpe_portfolio(returns, min_weight=min_w_iii, max_weight=max_w_iii)
risk_ms_iii, ret_ms_iii = portfolio_risk_return(w_ms_iii, returns)

# 2. Definir el rango de retornos objetivo
# El retorno máximo se limita seleccionando los 20 mejores activos al 5%
sorted_rets = np.sort(expected_return)[::-1]
max_possible_ret_iii = np.sum(sorted_rets[:20] * max_w_iii)
# Rango desde GMV hasta un poco menos del máximo posible para asegurar convergencia
target_returns_iii = np.linspace(ret_gmv_iii, max_possible_ret_iii * 0.98, 40)

# 3. Bucle de Optimización para la Frontera
eff_frontier_risk_iii = []
for tr in target_returns_iii:
    w_opt = min_risk_portfolio(returns, target_return=tr, min_weight=min_w_iii, max_weight=max_w_iii)
    risk = portfolio_risk_return(w_opt, returns)[0]
    eff_frontier_risk_iii.append(risk)

# 4. Grafica
plt.figure(figsize=(10, 7), facecolor='white')
ax = plt.gca()

# Activos Individuales
plt.scatter(sel_vols, expected_return, color=PALETA_AESTHETIC['activos'], alpha=0.4, s=70, edgecolor='white', label='Activos (n=40)', zorder=2)

# Frontera Bounded
plt.plot(eff_frontier_risk_iii, target_returns_iii, color=PALETA_AESTHETIC['cabecera'], linewidth=3.5, label='Frontera III (0% - 5%)', zorder=3)

# Marcadores Notables
plt.scatter(risk_gmv_iii, ret_gmv_iii, color=PALETA_AESTHETIC['gmv'], marker='*', s=350, edgecolor='white', label='GMV Bounded', zorder=5)
plt.scatter(risk_ms_iii, ret_ms_iii, color=PALETA_AESTHETIC['sharpe'], marker='o', s=180, edgecolor='white', label='Max Sharpe Bounded', zorder=5)

# En el escenario Bounded, la frontera suele estar muy concentrada.
# Ajustamos el zoom para ver la frontera y los activos cercanos.
vol_max_vis = min(max(sel_vols) * 0.8, 0.35) # Zoom un poco más cerrado que antes
plt.xlim(0, vol_max_vis)

# Ajuste del eje Y: centrado en el rango de la frontera
plt.ylim(ret_gmv_iii * 0.8, max_possible_ret_iii * 1.1)

plt.title('ESCENARIO III: OPTIMIZACIÓN BOUNDED WEIGHTS [0, 5%]', fontsize=13, fontweight='bold', color=PALETA_AESTHETIC['cabecera'], pad=25)

ax.xaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.yaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.xaxis.set_major_locator(mtick.MultipleLocator(0.05))
plt.xlabel(r'Volatilidad Mensual ($\sigma$)', fontweight='bold')
plt.ylabel(r'Retorno Mensual Esperado ($\mu$)', fontweight='bold')
plt.grid(True, linestyle=':', color=PALETA_AESTHETIC['borde_rejilla'], alpha=0.8)
plt.legend(fontsize=9, frameon=True, shadow=True, loc='upper right')
plt.tight_layout()
plt.show()


# --- CONFIGURACIÓN DEL ESCENARIO IV (RISK-FREE ASSET + BOUNDED WEIGHTS) ---
# Activo Libre de Riesgo
rf = 0.0035

# 1. Cartera Tangente (Max Sharpe) considerando el Risk-Free Rate y los límites de peso [0, 5%]
w_ms_iv = max_sharpe_portfolio(returns, risk_free_rate=rf, min_weight=min_w_iii, max_weight=max_w_iii)
risk_ms_iv, ret_ms_iv = portfolio_risk_return(w_ms_iv, returns)

# 2. Capital Allocation Line (CAL)
# La CAL une el activo libre de riesgo (0, rf) con la Cartera Tangente (risk_ms_iv, ret_ms_iv)
cal_risks = np.linspace(0, max(sel_vols) * 1.1, 50)
cal_returns = rf + cal_risks * ((ret_ms_iv - rf) / risk_ms_iv)

# 3. Grafica
plt.figure(figsize=(10, 7), facecolor='white')
ax = plt.gca()

# Dibujar Activos y Frontera Bounded (Escenario III) como referencia
plt.scatter(sel_vols, expected_return, color=PALETA_AESTHETIC['activos'], 
            alpha=0.3, s=60, edgecolor='white', label='Activos', zorder=2)
plt.plot(eff_frontier_risk_iii, target_returns_iii, color='gray', 
         linestyle='--', linewidth=1.5, label='Frontera Riesgosa (Bounded)', zorder=3)

# Dibujar la CAL (Capital Allocation Line)
zoom_x_max = min(max(sel_vols) * 0.9, 0.35) 
cal_risks_zoom = np.linspace(0, zoom_x_max, 50)
cal_returns_zoom = rf + cal_risks_zoom * ((ret_ms_iv - rf) / risk_ms_iv)

plt.plot(cal_risks_zoom, cal_returns_zoom, color=PALETA_AESTHETIC['cabecera'], linewidth=3, label='Capital Allocation Line (CAL)', zorder=4)

# Dibujar el Activo Libre de Riesgo y la Cartera Tangente
plt.scatter(0, rf, color='black', marker='D', s=120, label=f'Risk-Free Asset ({rf*100:.2f}%)', zorder=6)
plt.scatter(risk_ms_iv, ret_ms_iv, color=PALETA_AESTHETIC['sharpe'], marker='o', s=200, edgecolor='white', linewidth=1.5, label='Cartera Tangente (Bounded)', zorder=7)

plt.xlim(-0.01, zoom_x_max) # Empezamos un poco antes de 0 para ver bien el diamante negro
plt.ylim(0, max(max(expected_return), ret_ms_iv) * 1.1)

plt.title('ESCENARIO IV: RISK-FREE ASSET + BOUNDED WEIGHTS\n', fontsize=13, fontweight='bold', color=PALETA_AESTHETIC['cabecera'], pad=20)

# Formato de porcentaje
ax.xaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.yaxis.set_major_formatter(mtick.PercentFormatter(1.0))
ax.xaxis.set_major_locator(mtick.MultipleLocator(0.05))

plt.xlabel(r'Volatilidad Mensual ($\sigma$)', fontweight='bold')
plt.ylabel(r'Retorno Mensual Esperado ($\mu$)', fontweight='bold')
plt.grid(True, linestyle=':', color=PALETA_AESTHETIC['borde_rejilla'], alpha=0.6)
plt.legend(fontsize=9, frameon=True, shadow=True, loc='upper left')
plt.tight_layout()
plt.show()





# Resumen de Carteras Maximo Sharpe
resumen_carteras = pd.DataFrame({
    'Escenario': ['I (Unconstrained)', 'II (Long-Only)', 'III (Bounded 5%)', 'IV (Tangente Bounded)'],
    'Retorno (%)': [ret_ms * 100, ret_ms_ii * 100, ret_ms_iii * 100, ret_ms_iv * 100],
    'Volatilidad (%)': [risk_ms * 100, risk_ms_ii * 100, risk_ms_iii * 100, risk_ms_iv * 100],
    'Sharpe Ratio': [(ret_ms - rf)/risk_ms if risk_ms > 0 else 0, 
                     (ret_ms_ii - rf)/risk_ms_ii if risk_ms_ii > 0 else 0, 
                     (ret_ms_iii - rf)/risk_ms_iii if risk_ms_iii > 0 else 0, 
                     (ret_ms_iv - rf)/risk_ms_iv if risk_ms_iv > 0 else 0]
})

df_t4 = resumen_carteras.copy()
t4 = aplicar_estilo(df_t4.style, "04. RESUMEN DE CARTERAS TANGENTES (MÁXIMO SHARPE)")\
    .format({'Retorno (%)': "{:.2f}%", 'Volatilidad (%)': "{:.2f}%", 'Sharpe Ratio': "{:.3f}"})\
    .background_gradient(cmap='YlGn', subset=['Sharpe Ratio'])








# %% -------------------------------------------------------------------------
# FASE 7: CREACION DEL HTML DE TABLAS 
# 1. Creamos una variable para acumular el contenido del reporte
reporte_html = """
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f8f9fa; }
        .contenedor-tabla { margin-bottom: 50px; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        hr { border: 0; border-top: 2px solid #1a2a6c; margin: 40px 0; }
    </style>
</head>
<body>
    <h1 style="color: #1a2a6c; text-align: center;">OPTIMIZACIÓN DE CARTERA</h1>
    <p style="text-align: center; color: #666;"/p>
"""

# 2. Anadir tablas
reporte_html += f'<div class="contenedor-tabla">{t1.to_html()}</div>'
reporte_html += f'<div class="contenedor-tabla">{t2.to_html()}</div>'
reporte_html += f'<div class="contenedor-tabla">{t3.to_html()}</div>'
reporte_html += f'<div class="contenedor-tabla">{t4.to_html()}</div>'

# 3. Cerrar html y guardar archivo
reporte_html += "</body></html>"

with open("Practica_carteras_fmf.html", "w", encoding="utf-8") as f:
    f.write(reporte_html)

