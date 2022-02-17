% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
%BFS applies Breadth First Search algorithm to create a new tree from a given tree.
function tree=bfs(tree,level)
    if isempty(tree)
        return;
    end
    tree.level=level;
    if ~isempty(tree.kids)
        tree.kids{1}=bfs(tree.kids{1},level-1);
        tree.kids{2}=bfs(tree.kids{2},level-1);
    end
end
