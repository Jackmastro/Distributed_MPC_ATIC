% Create first figure
fig1 = figure;
x = linspace(0, 2*pi, 100);
y1 = sin(x);
plot(x, y1);
xlabel('x-axis', 'Interpreter', 'latex');
ylabel('y-axis', 'Interpreter', 'latex');
title('Sample Plot 1', 'Interpreter', 'latex');
grid on;

% Create second figure
fig2 = figure;
y2 = cos(x);
plot(x, y2);
xlabel('x-axis', 'Interpreter', 'latex');
ylabel('y-axis', 'Interpreter', 'latex');
title('Sample Plot 2', 'Interpreter', 'latex');
grid on;

% Save the first figure as a TikZ file to the Plots folder with additional options
saveTikzPlot('sample_plot1.tex', fig1, 'height', '\figureheight', 'width', '\figurewidth');

% Save the second figure as a TikZ file to the Plots folder with additional options
saveTikzPlot('sample_plot2.tex', fig2, 'height', '\figureheight', 'width', '\figurewidth');
