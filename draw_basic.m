showLabels = true;   % flag to determine whether to show node labels
prevIdx = [];         % keeps track of 1st node clicked in creating edges
selectIdx = [];       % used to highlight node selected in listbox
pts = zeros(0,2);     % x/y coordinates of vertices
adj = sparse([]);     % sparse adjacency matrix (undirected)
edd=sparse([]);

npoly = 5; % number of sides in regular polygon
sideLength = 1;
%myrad = 1; % Circumscribed radius
myrad = (sideLength * sin(0.5*(pi-(2*pi)/npoly)))/sin((2*pi)/npoly); % Circumscribed radius
disp('myrad')
disp(num2str(myrad))
xcenter = 0; % center of circumscribed circle (x coordinate)
ycenter = 0; % center of circumscribed circle (y coordinate)

MinXLim=-1.5*myrad;
MaxXLim=1.5*myrad;

MinYLim=-1.5*myrad;
MaxYLim=1.5*myrad;

lengthTotal = 0;

h.fig = figure('Name','Interactive Graph', 'Resize','off');

h.ax = axes('Parent',h.fig,'XLim',[MinXLim MaxXLim], 'YLim',[MinYLim MaxYLim], 'XTick',[], 'YTick',[], 'Box','on', ...
    'Units','pixels', 'Position',[100 20 380 380]);
h.pts = line(NaN, NaN, 'Parent',h.ax, 'HitTest','off', ...
      'Marker','o', 'MarkerSize',10, 'MarkerFaceColor','b', ...
      'LineStyle','none');
h.selected = line(NaN, NaN, 'Parent',h.ax, 'HitTest','off', ...
    'Marker','o', 'MarkerSize',10, 'MarkerFaceColor','y', ...
    'LineStyle','none');
h.prev = line(NaN, NaN, 'Parent',h.ax, 'HitTest','off', ...
    'Marker','o', 'MarkerSize',20, 'Color','r', ...
    'LineStyle','none', 'LineWidth',2);
h.edges = line(NaN, NaN, 'Parent',h.ax, 'HitTest','off', ...
    'LineWidth',2, 'Color','g');
h.txt1 = [];
h.txt2 = [];
h.txt3 = [];
% disp(h.ax)

for i=1:100
    %if poly==1
    for nsides=0:npoly
        thetanow = nsides*(2*pi/npoly);
        if npoly/2 == round(npoly/2) % testing if it's an even number of sides
          thetanow = thetanow + pi/npoly
        endif
        pts(end+1,:) = [xcenter+myrad*sin(thetanow), ycenter+myrad*cos(thetanow)];
        %disp(pts)
        adj(end+1, end+1)=0;
        % update GUI
      selectIdx = [];
      
      
      % edges
      
      p = nan(3*nnz(adj),2);
      [i,j] = find(adj);
      p(1:3:end,:) = pts(i,:);
      p(2:3:end,:) = pts(j,:);
      set(h.edges, 'XData',p(:,1), 'YData',p(:,2))
      
      % nodes
      set(h.pts, 'XData',pts(:,1), 'YData',pts(:,2))
      set(h.prev, 'XData',pts(prevIdx,1), 'YData',pts(prevIdx,2))
      set(h.selected, 'XData',pts(selectIdx,1), 'YData',pts(selectIdx,2))
      
      % list of nodes
      
      
      %set(h.list, 'String',num2str(pts,'(%.3f,%.3f)'))
      
      % node labels
      if ishghandle(h.txt1)
          delete(h.txt1);
      end
      if ishghandle(h.txt2)
          delete(h.txt2);
      end
      if showLabels
          %set(h.menu, 'Checked','on')
          h.txt1 = text(pts(:,1)+0.01, pts(:,2)+0.01, ...
              num2str((1:size(pts,1))'), ...
              'HitTest','off', 'FontSize',8);
          
      else
          %set(h.menu, 'Checked','off')
      end
      
      
      if ~isempty(find(adj, 1))
          [xi,yi,val]=find(adj);
          h.txt2 = text((pts(xi,1)+pts(yi,1))/2, (pts(xi,2)+pts(yi,2))/2, ...
              num2str( val), ...
              'HitTest','off', 'FontSize',8);
      end
      
      % force refresh
      drawnow
    end
    
    % get location of mouse click (in data coordinates)
    waitforbuttonpress;
    p = get(h.ax, 'CurrentPoint');
%     disp(p)
    % determine whether normal left click was used or otherwise
    if strcmpi(get(h.fig,'SelectionType'), 'Normal')
        % add a new node
        pts(end+1,:) = p(1,1:2);
        %disp(pts)
        adj(end+1,end+1) = 0;
    else
        % add a new edge (requires at least 2 nodes)
        if size(pts,1) < 2, return; end
        
        % hit test (find node closest to click location: euclidean distnce)
        %[dst,idx] = min(sum(bsxfun(@minus, pts, p(1,1:2)).^2,2));
        
        [dst,idx] = min((pts(:,1)-p(1,1)).^2+(pts(:,2)-p(1,2)).^2);
        %             if sqrt(dst) > 0.025, return; end
        
        if isempty(prevIdx)
            % starting node (requires a second click to finish)
            prevIdx = idx;
        else
            % add the new edge
            lengthTotal = lengthTotal + sqrt(((pts(prevIdx,1)-pts(idx,1))^2)+((pts(prevIdx,2)-pts(idx,2))^2));
            delete(h.txt3)
            h.txt3 = text(MinXLim + 0.3*myrad, MaxYLim - 0.3*myrad, ...
              strcat('Total Length: ', num2str(lengthTotal)), ...
              'HitTest','off', 'FontSize',15);
            adj(prevIdx,idx) =sqrt(((pts(prevIdx,1)-pts(idx,1))^2)+((pts(prevIdx,2)-pts(idx,2))^2));
            
            prevIdx = [];
            
        end
    end
    
    % update GUI
    selectIdx = [];
    
    
    % edges
    
    p = nan(3*nnz(adj),2);
    [i,j] = find(adj);
    p(1:3:end,:) = pts(i,:);
    p(2:3:end,:) = pts(j,:);
    set(h.edges, 'XData',p(:,1), 'YData',p(:,2))
    
    % nodes
    set(h.pts, 'XData',pts(:,1), 'YData',pts(:,2))
    set(h.prev, 'XData',pts(prevIdx,1), 'YData',pts(prevIdx,2))
    set(h.selected, 'XData',pts(selectIdx,1), 'YData',pts(selectIdx,2))
    
    % list of nodes
    
    
    %set(h.list, 'String',num2str(pts,'(%.3f,%.3f)'))
    
    % node labels
    if ishghandle(h.txt1)
        delete(h.txt1);
    end
    if ishghandle(h.txt2)
        delete(h.txt2);
    end
    if showLabels
        %set(h.menu, 'Checked','on')
        h.txt1 = text(pts(:,1)+0.01, pts(:,2)+0.01, ...
            num2str((1:size(pts,1))'), ...
            'HitTest','off', 'FontSize',8);
        
    else
        %set(h.menu, 'Checked','off')
    end
    
    
    if ~isempty(find(adj, 1))
        [xi,yi,val]=find(adj);
        h.txt2 = text((pts(xi,1)+pts(yi,1))/2, (pts(xi,2)+pts(yi,2))/2, ...
            num2str( val), ...
            'HitTest','off', 'FontSize',8);
    end
    
    % force refresh
    drawnow
end