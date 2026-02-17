function plotHoughCell(image, accumulator, r_idx, theta_idx)
    % Extragerea dimensiunilor imaginii
    [rows, cols] = size(image);
    
    % Conversia indexului r la valoarea r în spațiul Hough
    max_rho = sqrt(rows^2 + cols^2);
    r = r_idx - max_rho;
    
    % Conversia indexului theta la valoarea theta în spațiul Hough
    num_theta = size(accumulator, 2);
    theta = (theta_idx - 1) * pi / num_theta;
    
    % Calcularea liniilor corespunzătoare în imaginea originală
    x = 1:cols;
    y = (r - x * cos(theta)) / sin(theta);
    
    % Afisarea liniilor
    imshow(image);
    hold on;
    plot(abs(y), abs(x), 'r', 'LineWidth', 2);
    hold off;
    title('Liniile corespunzatoare celulei din spatiul Hough');
    xlabel('Coloana');
    ylabel('Rand');
end
