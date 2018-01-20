function sorted_factor = SortVar( F )

sorted_factor = struct('var',[],'card',[],'val',[]);
[out, idx] = sort(F.var); 
sorted_factor.var = out;
sorted_factor.card = F.card(idx);
new_val = zeros(1,prod(sorted_factor.card));
original_assign = IndexToAssignment(1:prod(F.card), F.card);
for i = 1:prod(F.card)
   old_assign = original_assign(i,:);
   new_assign = old_assign(idx);
   new_val(AssignmentToIndex(new_assign, sorted_factor.card)) = F.val(i);
end
sorted_factor.val = new_val;
end

