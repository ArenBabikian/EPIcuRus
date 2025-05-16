function new_preds = apply_repair(preds, indiv)
    
    % disp('Contents of preds:');
    % for idx = 1:length(preds)
    %     disp(['Predicate ', num2str(idx), ':']);
    %     disp(preds(idx));
    % end

    new_preds = preds; % Initialize new_preds with the original preds
    
    start_ind = 1;
    for j = 1:length(preds)
        if isfield(new_preds(j), 'A')
            n = length(new_preds(j).A);
            new_preds(j).A = new_preds(j).A .* indiv(start_ind:start_ind+n-1);
            start_ind = start_ind + n; % Remove used elements
        end
        if isfield(new_preds(j), 'b')
            new_preds(j).b = new_preds(j).b * indiv(start_ind);
            start_ind = start_ind + 1;
        end
    end

    % disp('Contents of new_preds:');
    % for idx = 1:length(preds)
    %     disp(['Predicate ', num2str(idx), ':']);
    %     disp(new_preds(idx));
    % end
    % error('yaba')

end