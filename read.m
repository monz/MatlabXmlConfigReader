function [ config ] = read( configfile, rootNode )
%READCONFIG Summary of this function goes here
%   Detailed explanation goes here
    configTree = xmlread(configfile);
    
    % extract ctcom node
    ctcomNode = configTree.getElementsByTagName(rootNode).item(0);
    
    if ~strcmp(rootNode, ctcomNode.getNodeName())
        error('Could not extract root node from config file');
    end
    
    config = processNode(ctcomNode);
    
    function [ struct ] = processNode( node )
    
        nodeChildren = node.getChildNodes();
        numOfChildren = nodeChildren.getLength();
        
        struct = [];
        % go through all children
        for n = 1:numOfChildren
            child = nodeChildren.item(n-1);
            name = char(child.getNodeName());
            numOfSubChildren = child.getChildNodes().getLength();
            % check if recursion required
            if numOfSubChildren > 1
                struct.(name) = processNode( child );
            else
                % check if is an actual node, if '#text' then it is a newline
                if strcmp('#text', child.getNodeName())
                    continue;
                end

                % extract name and value of child node
                name = char(child.getNodeName());
                value = char(child.getFirstChild().getNodeValue());
                % if field already exist create cell of values
                if isfield(struct, name)
                    struct = {struct.(name) value};
                % if struct is of type cell, append value to the end
                elseif iscell(struct)
                    struct{end+1} = value;
                % add struct field if it does not exist
                else
                    struct.(name) = value;
                end
            end
        end
    
    end

end

