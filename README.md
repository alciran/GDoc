<p align="center">
<a href="https://travis-ci.org/laravel/framework"><img src="https://travis-ci.org/laravel/framework.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

# GDoc
Gerador de arquivos HTML de documentação.

## Desenvolvedor

- **[Alciran Franco](https://github.com/alciran)** - \<18000223@uepg.br> - \<alciranfranco@gmail.com>


## Sobre o GDoc
GDoc é uma ferramenta que apresenta uma estrutura de páginas de documentação pré definida, bastando apenas escrever e executar o script de compilação para gerar página de documentação. Os ganhos com a utilização dessa ferrramenta são:

- Organização  => Documentação de um projeeto de forma organizada, de fácil gerência e manutenção.
- Padronização => Todas as páginas de documentação seguem o mesmo padrão definido.
- Agilidade    => As estruturas das páginas já serão criadas automaticamente, preocupando-se apenas com a escrita da documentação em si .

## Estrutura
A estrutra do GDoc é baseada em projetos e packages. Um projeto de documentação é referente ao assunto mais macro, amplo. O Package é um pacote de documentação de um projeto, que no fim se tornará uma página contento seções e subseções de tópicos referentes ao package que tem referencia direta ao projeto.

## Estrutura das Páginas
As páginas geradas são referentes ao projeto e seu(s) package(s). A página de projeto irá conter um card para cada package, trazendo informações referente a este e um link para acesso a dua determinada página. A página de package irá conter todos os componentes dentro da tag **compile{ }compile**, e dos imports de arquivos .gdocs existentes dentro da tag. A configuração do projeto pode ser gerenciada no arquivo de configuração **project.conf** dentro do diretório raiz do projeto, e a configuração do package no arquivo **package.conf** dentro do doretótio raiz do package

## Estrutura de diretórios
| Diretório                          | Descrição                                             |
|------------------------------------|-------------------------------------------------------|
| {Projeto}                          | Diretório referente ao projeto criado.                |
| {Projeto}/packages                 | Diretório que contém os packages do projeto.          |
| {Projeto}/public_gdocs             | Diretório para arquivos .gdoc público e componentes.  |
| {Projeto}/packages/{Package}/gdocs | Diretório para armazenar os arquivos .gdoc do package.|
| /public/help/dist                  | Diretório com arquivos e bibliotecas utilizadas para as páginas html. |
| /public/help/{Projeto}             | Diretório para armazenamento dos arquivos html referente ao projeto. |
| /public/help/{Projeto}/packages    | Diretório para armazenamento dos arquivos html referente ao(s) package(s) de um projeto. |

# Binários
Atualmente são dois binários, o **gdoc_manager.sh** referente a criação e remoção de projeto e package, e o binário **gdoc_compiler.sh** referente ao processo de criação das páginas em html de acordo com a estrutura e arquivos .gdoc do(s) package(s) do projeto.

# Comandos

## Para o **gdoc_manager.sh**, os comandos devem ser executados a partir do diretório **GDoc**.
Criar novo projeto, basta executar o comando abaixo e preenher os dados como nome do projeto e owner (Done e responsável pelo projeto):

    ./gdoc_manager.sh --create-project ou ./gdoc_manager.sh -cpr

Criar um novo projeto dentro de uma estrutura de diretório

    ./gdoc_manager -cpr /diretorio/subdiretorio

Para remover um projeto, deve-se utilizar o seguinte comando passando caminho do diretótio do projeto a ser excluído:

    ./gdoc_manager --remove-project /caminho/do/ptojeto ou ./gdoc_manager -rpr /caminho/do/ptojeto

Por exemplo, para remover o projeto Teste dentro do diretório projects:

    ./gdoc_manager --remove-projet projects/Teste    

Para criar novo package, deve-se passar como parâmetro a localização do diretório do projeto. Após executar o comando abaixo, deve-se preenher os dados como nome do package e author (quem escreve a documentação). Por exemplo, para criar um novo package no projeto Teste:

    ./gdoc_manager --create-package projects/Teste ou ./gdoc_manager -cpk projects/Teste

Para remover um package,  deve-se passar como parâmetro a localização do diretório do package, por exemplo, para remove ro package **Package** do projeto Teste:
    
    ./gdoc_manager --remove-package projects/Teste/packages/Package ou ./gdoc_manager -rpk projects/Teste/packages/Package

Sempre após remover um package, é questionado se deseja-se compilar a projeto novamente. Como o package foi excluído, a paǵina html do projeto deve ser recompilada para remover o card com o link e as informações referente a ele. Caso queira recompilar o projeto, basta aceitar, se recusar o projeto não é compilado. Mas **Atenção**, ao não compilar durante a remoção, lembre-se de compilar novamente em algum momento depois para não ficar um card referente a um package não existente lá na página do projeto.

## Para o **gdoc_compiler.sh**, os comandos devem ser executados a partir do diretório do **Projeto**.
Por exemplo, para compilar o projeto **Teste**, a partir do dirtório **GDoc**, primero deve-se ir até o diretório raiz do projeto:

    cd projects/Teste

Dentro do diretório raiz do projeto **Teste** podemos executar o compilador:

    ./gdoc_compiler.sh

Se não for passado nenhum parâmento, é compilado todos os packages do projeto. Para compilar um ou mais packages específicos, estes devem ser passados seus nomes por parâmetro. Para mais de um package, deve-se separá-los por vírgula *,*, por exemplo:

Para um package:

    ./gdoc_compiler.sh package1

Para mais de um package:

    ./gdoc_compiler.sh package1,package2

Para packages com nomes compostos, deve-se inserir o nome do package dentro de aspas duplas **"**.

    ./gdoc_compiler.sh "package composto"

Ou para mais de um package:

    ./gdoc_compiler.sh package1,"package composto"

## Outras opções do compiler:

Para verificar apenas a saída do comando, e se etá tudo corretos com a estrutura dos arquivos gdoc de um package, pode utilizar a opção **--test** ou **-t** do binário compiler. Ao passar essa opção o(s) package(s) não é compilado, apenas retornar se a estrutura e sintaxe dos arquivos estão corretas.

Para todos os packages:

    ./gdoc_compiler.sh --test

Para um package(s()) específico(s):

    ./gdoc_compiler.sh package1 --test
    ./gdoc_compiler.sh package1,package2 --test

Existe também de compilar apenas a página de projeto. Por padrão a página de projeto é recompilada sempre após a execução da copilação da(s) página(s) de package(s), porém pode-se compilar apenas a html página de projeto através do comando:

    ./gdoc_compiler.sh --compile-project








# Integração com Laravel
Para integrar com o Laravel, basta fazer o download do .zip ou clone do projeto, copiar o diretório **GDoc** da raiz do projeto para dentro do diretório raiz do seu projeto Laravel. Depois, basta copiar o diretório **/public/help** para dentro do diretório /public do seu projeto Laravel.

