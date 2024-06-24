%CLICKABLELEGEND  Enables interactions when clicking on legend entries.
%   CLICKABLELEGEND() finds the legend of the current axis and adds a
%   callback function to the legend items that toggles the visibility of
%   the corresponding plot elements on clicks.
% 
%   CLICKABLELEGEND('demo') shows demo plots that illustrate the
%   possibilities of styling the plot elements (see additional arguments
%   below).
% 
%   CLICKABLELEGEND('test') shows test plots that can be used to check this
%   implementation.
% 
%   CLICKABLELEGEND can be called with an axes handle or legend handle, or
%   assigned directly to the legend's ItemHitFcn via
%       l = legend();
%       l.ItemHitFcn = @CLICKABLELEGEND;
%   or 
%       l = legend();
%       l.ItemHitFcn = @(src, evt) CLICKABLELEGEND(src, evt, varargin{:});
% 
%   CLICKABLELEGEND with additional arguments allows to specify the desired
%   style of the plot elements, e.g.,
%       CLICKABLELEGEND(gca, 'LineStyle', '--', 'Color', 'k')
%   switches the style and color of the lines of the current axis whenever
%   clicked.
% 
function clickableLegend(varargin)

% Launch the test or demo if desired
if nargin > 0 && ischar(varargin{1}) 
    if strcmpi(varargin{1}, 'demo')
        demoInteractiveLegend(varargin{2:end});
    elseif strcmpi(varargin{1}, 'test')
        testInteractiveLegend(varargin{2:end});
    end % if
    return;
end % if

% Find legend handle
args = findLegendAndReplace(varargin); % Now first element is legend handle
if length(args) > 1 && endsWith(class(args{2}), 'ItemHitEventData')
    % This is a callback execution
    if nargin == 2
        toggleVisibility(varargin{:});
    else
        toggleStyle(varargin{:});
    end % if
else
    % This is to add the callback function
    style = args(2:end);
    assert(mod(length(style), 2) == 0, 'Number of style arguments must be even as name-value pairs.');
    args{1}.ItemHitFcn = @(src, evt) clickableLegend(src, evt, style{:});
end % if
end % function


function args = findLegendAndReplace(args)
if isempty(args)
    args = {legend()};
elseif endsWith(class(args{1}), 'Axes')
    args{1} = legend(args{1});
elseif ~endsWith(class(args{1}), 'Legend')
    args = [{legend()}, args];
end % if
assert(endsWith(class(args{1}), 'Legend'), 'The first argument should now be a legend handle');
end % function


function toggleVisibility(~, evt)
if strcmp(evt.SelectionType, 'open') % show everything
    namesInLegend = evt.Source.String;
    allElements = allchild(evt.Peer.Parent);
    elementIsInLegend = arrayfun(@(x) strcmp(x.HandleVisibility, 'on') && isprop(x, 'DisplayName') && any(strcmp(x.DisplayName, namesInLegend)), allElements);
    set(allElements(elementIsInLegend), 'Visible', 'on');
    
elseif strcmp(evt.SelectionType, 'extend') % hide everything else
    namesInLegend = evt.Source.String;
    allElements = allchild(evt.Peer.Parent);
    elementIsInLegend = arrayfun(@(x) strcmp(x.HandleVisibility, 'on') && isprop(x, 'DisplayName') && any(strcmp(x.DisplayName, namesInLegend)), allElements);
    otherElements = setdiff(allElements(elementIsInLegend), evt.Peer, 'stable');
    
    evt.Peer.Visible = 'on';
    set(otherElements, 'Visible', 'off');

else
    if strcmp(evt.Peer.Visible, 'on')
        evt.Peer.Visible = 'off';
    else
        evt.Peer.Visible = 'on';
    end % if
end % if
end % function


function toggleStyle(~, evt, varargin)
assert(mod(length(varargin), 2) == 0, 'Number of arguments must be even.');
names = varargin(1:2:end);
values = varargin(2:2:end);

persistent knownHandles
if isempty(knownHandles)
    knownHandles = {};
end % if

peerIsMatch = cellfun(@(x) x.handle == evt.Peer, knownHandles);
if any(peerIsMatch)
    thisHandle = knownHandles{peerIsMatch}.handle;
    currentValues = cellfun(@(x) get(thisHandle, x), names, 'uniformOutput', false);
    
    if isequal(values, currentValues)
        valuesToSet = knownHandles{peerIsMatch}.previousValues;
    else
        valuesToSet = values;
    end % if
else
    newHandle.handle = evt.Peer;
    newHandle.previousValues = cellfun(@(x) get(evt.Peer, x), names, 'uniformOutput', false);
    knownHandles{end+1} = newHandle;
    valuesToSet = values;
end % if

for i = 1:length(names)
    set(evt.Peer, names{i}, valuesToSet{i});
end % for
end % function


function demoInteractiveLegend(varargin)
% Toggle the line style
createDummyFigure();
clickableLegend(legend(), 'LineStyle', '--');

% Toggle line width
createDummyFigure();
clickableLegend(legend(), 'LineWidth', 5);

% Toggle the color
createDummyFigure();
clickableLegend(legend(), 'Color', 0.8*ones(1,3));

% Toggle the color and the style
createDummyFigure();
clickableLegend(legend(), 'LineStyle', ':', 'Color', 0.8*ones(1,3));

% Toggle markers
createDummyFigure();
clickableLegend(legend(), 'Marker', '.');
end % function


function testInteractiveLegend(varargin)
% Test basic usage
createDummyFigure();
l = legend();
l.ItemHitFcn = @clickableLegend;

% Test basic usage
createDummyFigure();
l = legend();
l.ItemHitFcn = @(src, evt) clickableLegend(src, evt, varargin{:});

% Test usage as function for legend handle
createDummyFigure();
clickableLegend(legend(), varargin{:});

% Test usage as function for axes handle
createDummyFigure();
clickableLegend(gca, varargin{:});

% Test usage without specifying anything
createDummyFigure();
clickableLegend(varargin{:});
end % function


function createDummyFigure()
figure;
x = linspace(0, 10, 100);
plot(x, sin(x), 'DisplayName', 'sin(x)');
hold on;
grid on;
for offset = 5:5:20
    plot(x, sin(x + offset), 'DisplayName', sprintf('sin(x+%g)', offset));
end % for
title(['Demo plot of ', mfilename, ' -> click on legend entries']);
end % function