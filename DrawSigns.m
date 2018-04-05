%% Draw evacualation signs and corridor's boundary
hold on;
plot(boundPos(:, 1), boundPos(:, 2), 'color', [0 0 0], 'linewidth', 1.4);
scatter(signPos(:, 1), signPos(:, 2), 'filled');
for cnt = 1: length(signPos)
    switch signType(cnt)
        case 0
            showTypeText = 'Exit';
            offset = 30;
        case 1
            showTypeText = 'Left';
            offset = -30;
        case 2
            showTypeText = 'right';
            offset = -30;
        case 3
            showTypeText= 'two-way';
            offset = -30;
    end
    text(signPos(cnt, 1) - 25, signPos(cnt, 2) + offset, showTypeText, 'FontSize', 15);
end
hold off;