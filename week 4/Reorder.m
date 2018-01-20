function T = Reorder(F,dvar)
    iF = zeros(1,length(F.var)); % map F->d
    iD = zeros(1,length(dvar)); % map d->F
    for i = 1:length(dvar)
        k = find(dvar == F.var(i),1);
        iF(k) = i;
        iD(i) = k;
    end
    T = F;
    T.card = F.card(iF);
    T.var = F.var(iF);
    val = zeros(1,prod(T.card));
    enum = IndexToAssignment(1:prod(F.card), F.card);
    for i = 1:length(enum)
        num = enum(i,:);
        indx = AssignmentToIndex(num(iF), T.card);
        val(indx) = F.val(i);
    end
    T.val = val;
end

