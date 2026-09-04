with Ada.IO_Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Command_line; use Ada.Command_line;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;
with Naive;


procedure pagerank is
	No_File_Error, Argument_I_Error, Argument_A_Error : Exception;
	File : Ada.Text_IO.File_Type;
	package SU renames Ada.Strings.Unbounded;
	use SU;
	alpha : Float := 0.85;
    Somme : Float;
    Mode_Naive : Boolean:=False;
	Nbr_Iter : Integer := 150;
	Nom_Fichier : SU.Unbounded_String;
	N : Integer;						--Nombre de pages du réseau
	Page1, Page2 : Integer;


    function Positif(char : in String) return Boolean is
    begin
	    if Float'Value(char) /= float(Integer'Value(char)) or Integer'Value(char) <= 0 then
		    raise Argument_I_Error;
	    else
	    	return(True);
	    end if;
    Exception
	    when Constraint_Error => raise Argument_I_Error;
    end Positif;

	function Est_Reel(ch : in String) return Boolean is
	begin
		if Float'Value(ch) <= 0.0 or Float'Value(ch) >= 1.0 then
			raise Argument_A_Error;
		else
			return(True); 
		end if;
	Exception
		when Constraint_Error => raise Argument_A_Error;
	end Est_Reel;


        	function Indice_Fichier return Integer is
		File_in : Boolean := False;
		i : integer := 0;
	begin
		while i < Argument_Count and not(File_in) loop
			i := i+1;
			File_in := (SU.Count(To_Unbounded_String(Argument(i)), ".net") = 1);
		end loop;
		if not(File_in) then
			raise No_File_Error;
		else
			return(i);
		end if;
	Exception
		when Constraint_Error => raise No_File_Error;
	end Indice_Fichier;
    

begin
	--Exploiter les paramètres de la ligne de commande
	if Argument_Count = 0 then
		raise No_File_Error;
	else
		for i in 1..Argument_Count loop
			if Argument(i) = "-I" and then Positif(Argument(i+1)) then
				Nbr_iter := Integer'Value(Argument(i+1));
			elsif Argument(i) = "-A" and then Est_Reel(Argument(i+1)) then
				alpha := Float'Value(Argument(i+1));
            elsif Argument(i) = "-P" then
                mode_Naive := True;
			end if;
		end loop;
    end if;

    open(File, In_File, Argument(Indice_Fichier));
	Get(File, N);


    --Déclarer les types et les variables qui dépendent de N.

    declare
        package Naive1 is new Naive(N);
        use Naive1;
        Type T_Vecteur_Integer is array(1..N) of Integer;
        Type T_Vecteur_Float is array(1..N) of Float;
        Type T_Poids is record                 
            Valeur : T_Vecteur_Float;           --Vecteur de Poids
            Page : T_Vecteur_Integer;           --Vecteur des indices
        end record;

        Pi, Pi_Suivant : T_Poids;

        Type T_Cellule;
        Type T_LCA is access T_Cellule;
        Type T_Cellule is record
            Page : Integer;
            Suivant : T_LCA;
        end record;
        Type T_Tableau is array (1..N) of T_LCA;    --Tableau qu'on va utiliser pour créer G
        Tab : T_Tableau;   
        curseur : T_LCA;


    -- La Procédure Trier -- 
        procedure Trier(Pi : in out T_Poids) is
            page_max, ind_max, inter_page : Integer;
            inter_val : Float;
        begin
            for i in 1..N loop
                page_max := Pi.Page(i);
                ind_max := i;
                for j in i..N loop
                    if Pi.Valeur(j) > Pi.Valeur(ind_max) then
                        page_max := Pi.Page(j);
                        ind_max := j;
                    end if;
                end loop;
                inter_page := Pi.Page(i);
                inter_val := Pi.Valeur(i);
                Pi.Page(i) := page_max;
                Pi.Valeur(i) := Pi.Valeur(ind_max);
                Pi.Page(ind_max) := inter_page;
                Pi.Valeur(ind_max) := inter_val;
            end loop;
        end Trier;
        
            -- Determiner le nombre de liens d'une page.
        function Nbr_Liens (Page : in T_LCA) return integer is
            S : Integer;
            curseur : T_LCA;
        begin
            curseur := Page;
            S := 0;
            while curseur /= Null loop
                S := S+1;
                curseur := curseur.All.Suivant;
            end loop;
            return(S);
        end Nbr_Liens;
        
        -- Ajouter une page 
        procedure Ajout_Page (Page_mere : in out T_LCA; Page_fille : in Integer) is
            curseur : T_LCA;
            Doublon : Boolean := False;
        begin
            if Page_mere = Null then
                Page_mere := new T_Cellule;
                Page_mere.All.Page := Page_fille;
                Page_mere.All.Suivant := Null;
            else
                curseur := Page_mere;
                while curseur.All.Suivant /= Null and not(Doublon) loop
                    if curseur.All.Page = Page_fille then
                        Doublon := True;
                    else
                        curseur := curseur.All.Suivant;
                    end if;
                end loop; 
                if not(Doublon) and curseur.All.Page /= Page_fille then
                    curseur.All.Suivant := new T_Cellule;
                    curseur := curseur.All.Suivant;
                    curseur.All.Page := Page_fille;
                    curseur.All.Suivant := Null;
                end if;
            end if;
        end Ajout_Page;
                    
        procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_LCA);

        procedure Vider (Page_mere : in out T_LCA) is
        curseur : T_LCA;
	    begin
		    while Page_mere /= Null loop
                curseur := Page_mere;
                Page_mere := Page_mere.All.Suivant;
                free(curseur);
            end loop;
	    end Vider;

    begin
        --Remplir le tableau Tab qu'on utilisera pour créer G.
        for i in 1..N loop
            Tab(i) := Null;
        end loop;
		while not end_of_File(File) loop
			Get(File,Page1);
            Get(File, Page2);
            Ajout_Page(Tab(Page1 + 1), Page2);
        end loop;
        close(File);

        --Initialiser le vecteur de poids
        for k in 1..N loop
            Pi.Valeur(k) := 1.0 / float(N);
            Pi.Page(k) := k - 1;
        end loop;

       
            declare
                G_Naive : Naive1.T_Matrice;          --Matrice G Naive
            begin
                --Initialiser G à la matrice S
                Initialiser0(G_Naive);

                for i in 1..N loop
	                if Nbr_Liens(Tab(i)) = 0 then
			            --Remplacer les éléments de cette ligne par des 1/N
			            for j in 1..N loop
                            Remplir(G_Naive,i,j,(1.0/float(N)));
		                end loop;
	                else
			            --Remplir les éléments de cette ligne
                        curseur := Tab(i);
			            while curseur /= Null loop
                            Remplir(G_Naive,i,curseur.All.page+1, (1.0/float(Nbr_Liens(Tab(i)))));
                            curseur := curseur.All.Suivant;
		                end loop;
	                end if;
                    Vider(Tab(i));
                end loop;
                -- matrice G finale 
                for i in 1..N loop
	                for j in 1..N loop
                        Remplir(G_Naive,i,j,alpha*Valeur(G_Naive,i,j) + (1.0 -alpha)/float(N));
		            end loop;
                end loop;
            -- Poids d'une page 
                
                for k in 1..Nbr_Iter loop
                    for i in 1..N loop
		                Somme := 0.0;
		                for k in 1..N loop
			                Somme := Somme + Pi.Valeur(k)*Valeur(G_Naive,k,i);
		                end loop;
			            Pi_Suivant.Valeur(i) := Somme;
		            end loop;
                    Pi.Valeur := Pi_Suivant.Valeur;
                end loop;
            end;
        
        


        --Trier le vecteur de poids 
        Trier(Pi);

        --Créer le fichier Pagerank.ord
        Create(File, Out_File,"PageRanktest.ord");
        for i in 1..N loop
            Put(File,Pi.Page(i), 0);
            New_line(File);
        end loop;
        close(File);

        --Créer le fichier Poids.p
        Create(File, Out_File, "Poidstest.p");
        Put(File, N, 0);
        Put(File, alpha, 2);
        Put(File, Nbr_iter, 4);
        New_line(File);
        for i in 1..N loop
            Put(File,Pi.Valeur(i), 0);
            New_line(File);
        end loop;
        close(File);
    end;
	
	
--Traiter les exceptions liées au traitement de la ligne de commande		
Exception
    when Argument_I_Error => Put_Line("Le paramètre -I doit être un entier naturel non nul.");
    when Argument_A_Error => Put_Line("Le paramètre -A doit être un réel compris entre 0 et 1.");
    when No_File_Error => Put_Line("Il manque le nom du fichier en paramètre.");

end pagerank;
