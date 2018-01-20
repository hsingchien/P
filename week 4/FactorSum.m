function U = FactorSum( F )
% F is a list of factors
U = struct('var',[],'card',[],'val',[]);
for m = 1:length(F)
   cur_f = F(m);
   new_var = union(cur_f.var, U.var);
   new_card = [];
   for i = 1:length(new_var)
       if(find(cur_f.var == new_var(i)))
           new_card = [new_card, cur_f.card(find(cur_f.var == new_var(i)))];
       else
           new_card = [new_card, U.card(find(U.var == new_var(i)))];            
       end  
   end
   assigns = IndexToAssignment(1:prod(new_card), new_card);
   new_val = zeros(1, prod(new_card));
   for j = 1:length(assigns)
        ass = assigns(j,:);
        uass = zeros(1,length(U.var));
        cass = zeros(1, length(cur_f.var));
        for k = 1:length(ass)
           this_var = new_var(k);
           uass(find(U.var == this_var)) = ass(k);
           cass(find(cur_f.var == this_var)) = ass(k);
        end
        if(isempty(U.val(AssignmentToIndex(uass, U.card))))
            add_val = cur_f.val(AssignmentToIndex(cass, cur_f.card));
        else
            add_val = U.val(AssignmentToIndex(uass, U.card)) + ...
            cur_f.val(AssignmentToIndex(cass, cur_f.card));
        end
        new_val(j) = add_val;
   end
   U.var = new_var;
   U.card = new_card;
   U.val = new_val;
end
    
end