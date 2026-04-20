%% =========================================================
%  FUNCTIE LOCALA - Calculul centrului 3D al unui vehicul
%% =========================================================
function pos3D = calculeaza_centru_3D(bbox, dispMap, u_mat, v_mat, m, n, f, cu, cv, b)
% Calculeaza pozitia 3D medie a pixelilor valizi din bounding box
%
% Returneaza [X, Y, Z] in metri, sau [] daca nu exista pixeli valizi
 
    col_start = max(1, bbox(1));
    row_start = max(1, bbox(2));
    col_end   = min(n, bbox(1) + bbox(3) - 1);
    row_end   = min(m, bbox(2) + bbox(4) - 1);
 
    % Masca bounding box cu disparitati valide
    masca = false(m, n);
    masca(row_start:row_end, col_start:col_end) = true;
    masca = masca & (dispMap > 0);
 
    [rows_idx, cols_idx] = find(masca);
 
    if isempty(rows_idx)
        pos3D = [];
        return;
    end
 
    % Reconstructie 3D pentru toti pixelii valizi
    X_vals = zeros(length(rows_idx), 1);
    Y_vals = zeros(length(rows_idx), 1);
    Z_vals = zeros(length(rows_idx), 1);
 
    for i = 1:length(rows_idx)
        r = rows_idx(i);
        c = cols_idx(i);
        d = dispMap(r, c);
        if d <= 0; continue; end
 
        Z = f * b / d;
        X = (u_mat(r,c) - cu) * Z / f;
        Y = (v_mat(r,c) - cv) * Z / f;
 
        X_vals(i) = X;
        Y_vals(i) = Y;
        Z_vals(i) = Z;
    end
 
    % Folosim mediana pentru robustete (mai putin sensibila la outlieri)
    valid = Z_vals > 0;
    if sum(valid) < 10
        pos3D = [];
        return;
    end
 
    pos3D = [median(X_vals(valid)), median(Y_vals(valid)), median(Z_vals(valid))];
end