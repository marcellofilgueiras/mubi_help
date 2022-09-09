# mubi_help
Importação e Faxina de Dados de 97 Excels de forma automática que fiz para uma cliente.

A empresa cliente presta serviços à médicos fazendo registro financeiro.
Existem dois tipos de arquivos .xls nos registros da empresa. Um **numXXXX_analitico.xls**, que continham os relatórios e valores detalhados dos procedimentos realizados, e u **numXXXX_sintetico.xls**, com a soma de todos os valores, sendo necessário cruzar esses dados após.


A cliente lia ".xls" na mão, ctrl c + ctrl v. Nas tabelas sinteéticos, haviam linhas em branco e linhas com caracteres específicos que teriam que ter lidas.
Com o número muito grande de arquivos, desenvolvi o codigo parar ler e faxinar em uma tabela automática ao invés do filtro ser feito manualmente com ctrl+c ctrl+v.


Os dados são sensíveis, por isso não upei as tabelas "data_raw" nem "exports" neste repositóro, apenas os códigos utilizados.
Faxinas maiores e análises não foram feitas por opção da cliente que já tinha suas fórmulas prontas no Excel.
