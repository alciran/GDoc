#!/bin/bash
#script para compilar arquivos linguagem gdoc em arquivos html
#Autor: Alciran Franco
#alciranfranco@gmail.com 

##### VARIAVEIS GLOBAIS #####
date=`date +"%d-%m-%Y_%H-%M-%S"`
public_files_dir="../../dist/files"
#Arquivo de log
file_log=""
generate_log=""
msg_log_before_check_var=""
#funcao --test, nao compila, apenas informa com a saida
test_option=0
compile_package_errors=0
#Arquivos temporariosutilizados na compilacao
package_temp_file=""
project_temp_file=""
section_sub_temp_file=""
#Variaveis com valores de configuracao do project em project.conf
project_name=""
project_name_no_space=""
owner=""
create_date_project=""
num_columns_cards=2
generate_links_page=false
#Variaveis com valores de configuracao do package (config{} do package.conf)
package_dir_name=""
package_name=""
package_name_no_space=""
colorTheme=""
author=""
occupation=""
email=""
docVersion=""
lastUpdate=""
generate_log=""
package_card_icon=""
package_description=""
#flag usada para inserir a linha de informacoes (versao, autor e data ultima atualizacao) na pagina
line_page_info=0
line_package_info_value=""
line_project_info_value=""
package_info=""
#Variaveis usadas na compilacao
compile_tag=0
#String utilizada para armazenar os links da sidebar
sidebar_links="<!--sidebar-->"
#arquivos de importacao
import=0
import_number=0
#variavies de seccao
section=0
section_number=0
section_line_open=0
section_file_open=""
#variavies de subseccao
subsection=0
subsection_number=0
subsection_line_open=0
subsection_file_open=""
#variavies de callout
callout=0
callout_number=0
callout_line_open=0
callout_file_open=""
#variaveis para compilacao dos texts
text=0
text_line_open=0
text_file_open=""
#variaveis para compilacao footer
footer=0
footer_number=0
footer_line_open=0
footer_file_open=""
#variaveis para simple gallery
gallery=0
gallery_number=0
gallery_line_open=0
gallery_file_open=""
gallery_columns=2
gallery_name=""
gallery_images=""
#variaveis para blocos de codigo
code_block=0
code_block_number=0
code_block_line_open=0
code_block_file_open=""
code_git_file=0
code_line=0
#variaveis componente imagem
image_line_open=0
image_file_open=""
#variaveis component video
video_line_open=0
video_file_open=""
##### FIM VARIAVEIS GLOBAIS #####

##### FUNCOES GLOBAIS #####
function print_message(){
  type=$1
  message=$2
  echo -e "$header $type $message"
  if [ "$generate_log" == "true" ] ; then
    echo "[$(date +"%d-%m-%Y %T")] $header $message" >> "$file_log"
  fi
}

function create_temp_files(){
  package_temp_file="../../logs/tmp/compile_package_$date.html"
  project_temp_file="../../logs/tmp/compile_project_$date.html"
  section_sub_temp_file="../../logs/tmp/compile_section_and_sub_$date.html"
  
  if [ ! -d "../../logs/tmp" ] ; then
    mkdir ../../logs/tmp
  fi

  touch $section_sub_temp_file
  touch $package_temp_file
  touch $section_sub_temp_file

}

function remove_temp_files(){
  if [ -e "$package_temp_file" ] ; then
    rm -rf "$package_temp_file"
  fi

  if [ -e "$project_temp_file" ] ; then
    rm -rf "$project_temp_file"
  fi

  if [ -e "$section_sub_temp_file" ] ; then
    rm -rf "$section_sub_temp_file"
  fi

}

function exit_with_error(){
  remove_temp_files
  print_message $error "$compile_not_possible - $close_with_error"
  exit -1
}

function exit_with_success(){
  package_name=$1
  remove_temp_files  
  print_message $ok "compiler: $project_name => $compile_successfully"
  exit 0
}

function copy_package_component(){
  $(cat ../../components/package/"$1" >> "$2")
}

function copy_project_component(){
  $(cat ../../components/project/"$1" >> "$2")
}

function generate_link(){
  if [ "$generate_links_page" == "true" ] ; then
    type=$1
    component_name="$2"

    consult=""
    last_link=""

    case $type in
    'p')
      consult="p;$component_name;"
    ;;
    's')
      consult="s;$component_name;"
      last_link="#section-$3"
    ;;
    'ss')
      consult="ss;$component_name;"
      last_link="#subsection-$3"
    ;;
    *)
      print_message $error "Tipo desconhecido para geração de link!"
    ;;
    esac

    if [ -n "$consult" ] ; then
      links_file="$package_dir_name/links.txt"
      if [ ! -e "$links_file" ] ; then
        touch "$links_file"
        echo "#Links gerados automaticamente durante a compilação" >> "$links_file"
        echo "#Tipo;Nome;link;Laravel link" >> "$links_file"
      fi
      test_value=$(cat "$links_file" | grep ^"$consult" )
      if [ -z "$test_value" ] ; then
        copy_package_component component_link "$links_file"
        $(sed -i "s|{{type}}|$type|g" "$links_file" )
        $(sed -i "s|{{component_name}}|$component_name|g" "$links_file" )
        $(sed -i "s|{{package_link}}|$package_name_no_space.html$last_link|g" "$links_file" )
        $(sed -i "s|{{project_name}}|$project_name|g" "$links_file" )
        $(sed -i "s|{{laravel_link}}|$package_name_no_space.html$last_link|g" "$links_file" )
      else
        temp_link="../../logs/tmp/link"
        if [ ! -e "$temp_link" ] ; then
          touch "$temp_link"
        fi      
        copy_package_component component_link "$temp_link"
        $(sed -i "s|{{type}}|$type|g" "$temp_link" )
        $(sed -i "s|{{component_name}}|$component_name|g" "$temp_link" )
        $(sed -i "s|{{package_link}}|$package_name_no_space.html$last_link|g" "$temp_link" )
        $(sed -i "s|{{project_name}}|$project_name|g" "$temp_link" )
        $(sed -i "s|{{laravel_link}}|$package_name_no_space.html$last_link|g" "$temp_link" )
        
        alt_value=$(cat "$temp_link" )
        $(sed -i "s|^$consult.*|$alt_value|g" "$links_file" )
        rm -f "$temp_link"
      fi    
    fi
  else
    if [ -e "$package_dir_name/links.txt" ] ; then
      rm -f "$package_dir_name/links.txt"
    fi
    if [ -e "../../../public/help/$project_name/links.html" ] ; then
      rm -f "../../../public/help/$project_name/links.html"
    fi
  fi
}

function print_info_built_package(){

  if [ $section_number -gt 0 ] ; then
    print_message $ok "$total_section_built $section_number"
  fi

  if [ $subsection_number -gt 0 ] ; then
    print_message $ok "$total_subsection_built $subsection_number"
  fi

  if [ $callout_number -gt 0 ] ; then
    print_message $ok "$total_callout_built $callout_number"
  fi

  if [ $gallery_number -gt 0 ] ; then
    print_message $ok "$total_gallery_built $gallery_number"
  fi

  if [ $code_block_number -gt 0 ] ; then
    print_message $ok "$total_code_block_built $code_block_number"
  fi

  if [ $test_option -eq 0 ] ; then
    print_message $ok "compiler: [$package_name] $compile_successfully"
  fi

}
##### FIM FUNCOES GLOBAIS #####

##### FUNCOES DE CHECAGEM ANTES DE INICIAR A COMPILACAO #####
function checkLanguage(){
  pathLang="../../languages/$LANGUAGE.lang"
  if [ -e $pathLang ] ; then
	  . $pathLang
  else
	  if [ -e ../../languages/en_US.lang ] ; then
		  . ../../languages/en_US.lang
	  else
		  echo -e "[GDoc]: [\033[00;31mErro\033[00m] Arquivo padrão de linguagem removido ou inexistente."
      echo "[GDoc]: Tente reinstalar ou recuperar manualmente o arquivo de linguagem."
		  exit 0;
	  fi
  fi
}

function check_before_compiler(){
  if [ -e project.conf ] ; then
    project_name="`cat project.conf | grep name= | cut -d= -f2`"
    generate_links_page="`cat project.conf | grep generate_links_page= | cut -d= -f2`"

    if [ -z "$project_name" ] ; then
      print_message $warning "$project_name_missing_in_package_conf"
      project_name="Project Name"
      project_name_no_space="Project_Name"
    else
      project_name_no_space=$(echo "$package_name" | sed 's/ /_/g')
    fi

    print_message $ok "$project_found '$project_name'"
  else
    print_message $error "$error_missing_file_project_config"
    exit_with_error
  fi

  if [ ! -d ../../logs ] ; then
    mkdir ../../logs
  fi

  if [ ! -d packages ] ; then
    print_message $error "$error_compile_missing_packages_directory $project_name"
    exit_with_error
  fi

  if [ -z "$(ls -A packages)" ]; then
    print_message $warning "$compile_exit_zero_packages"
    #remove arquivo links se existir
    
    if [ -e "../../../public/help/$project_name/links.html" ] ; then
      rm -f "../../../public/help/$project_name/links.html"
    fi
    #cria página do projeto em branco
    create_temp_files
    build_project_file_html    
    exit 0
  else
    num_pkgs=`ls -l ./packages | grep '^d' | wc -l`
    print_message "" "compiler: $num_directory_packages_found $num_pkgs"
    msg_log_before_check_var="$msg_log_before_check_var\n[$(date +"%d-%m-%Y %T")] $header compiler: $num_directory_packages_found $num_pkgs"
  fi  
}

function check_test_option(){
  if [ "$1" == "-t" ] || [ "$1" == "--test" ] || [ "$2" == "-t" ] || [ "$2" == "--test" ] ; then
    test_option=1  
    print_message "$warning" "compiler: $running_with_test_option" 
  fi
}

function check_last_line(){
  test_file="$1"
  total_lines=$(wc -l "$test_file" | awk '{print $1}' )
  last_line=$(sed -n ${total_lines}p "$test_file")

  if [ "$last_line" != " " ] ; then   
    echo -e  "\n \n " >> "$test_file"
  fi

}

function check_line_info(){
  line_info="$1"
  number_line_info=$2
  file_info="$3"

  #remove os espaços antes e depois da linha
  line_info=$(echo "$line_info" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') 
  #testa se a linha tem o padrão @(...) para a linha de informações do componente
  line_info=$(echo $line_info | grep ^"@(")

  if [ -z "$line_info" ] ; then
    print_message $error "$structure_line_info_unknow => $line $number_line_info $at $file_info"
    print_message "" "compiler: $structure_line_info"
    exit_with_error
  fi
}

function check_default_types(){
  color=$1
  return_val=1
  case $color in
    primary);;secondary);;success);;danger);;warning);;info);;light);;dark);;
    *)
    return_val=0
    ;;
  esac
  return "$return_val"
}

function check_default_types_callout(){
  color=$1
  return_val=1
  case $color in
    success);;danger);;warning);;info);;
    block-success);;block-danger);;block-warning);;block-info);;
    *)
    return_val=0
    ;;
  esac
  return "$return_val"
}

function check_default_types_languages(){
  language=$1
  return_val=1
  case $language in
    css);;git);;javascript);;handlebars);;http);;markup);;php);;python);;ruby);;vim);;yaml);;
  *)
    return_val=0
  ;;
  esac
  return "$return_val"
}

function check_file_exist(){
  file_name=$(echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  line_source=$2
  file_open="$3"
  if [ ! -e "../../../public/help/dist/files/$file_name" ] ; then
    print_message "$error" "'$file_name' $file_not_found => $line $line_source $at $file_open"
    exit_with_error
  fi
}

function check_ext_file_exist(){
  ping www.google.com -c 2 > /dev/null 2>&1
    if [ $? -eq 0 ] ; then
      URL="$1"
      URL=$(echo "$URL" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      line_source=$2
      file_open="$3"
      name_tag="$4"

      if ! wget --spider "$URL" 2>/dev/null; then
        print_message "$warning" "Link '$URL' [ 404 Not Found ] $at $name_tag tag 'src_ext' => $line $line_source $at $file_open" 
      fi
    fi
}

function check_if_close_tags(){
  if [ $section -eq 1 ] ; then
    print_message $error "$tag_section_not_close => $open_in $line $section_line_open $at $section_file_open"
    exit_with_error
  fi

  if [ $subsection -eq 1 ] ; then
    print_message $error "$tag_subsection_not_close => $open_in $line $subsection_line_open $at $subsection_file_open"
    exit_with_error
  fi

  if [ $callout -eq 1 ] ; then
    print_message $error "$tag_callout_not_close => $open_in $line $callout_line_open $at $callout_file_open"
    exit_with_error
  fi

  if [ $gallery -eq 1 ] ; then
    print_message $error "$tag_gallery_not_close => $open_in $line $gallery_line_open $at $gallery_file_open"
    exit_with_error  
  fi

  if [ $code_block -eq 1 ] ; then
    print_message $error "$tag_sc_gallery_not_close => $open_in $line $code_block_line_open $at $code_block_file_open"
    exit_with_error  
  fi

}

##### FIM FUNCOES DE CHECAGEM #####

##### FUNCOES COMPILAR COMPONENTES #####
function clear_variables_and_files(){
  #restaurar valores das varivaeis utilizadas
  package_dir_name=""

  #Variaveis com valores de configuracao do package (config{} do package.conf)
  package_name="";package_name_no_space="";colorTheme="";author="";occupation="";email="";docVersion="";lastUpdate="";generate_log="";package_card_icon="";package_description=""

  #flag usada para inserir a linha de informacoes (versao, autor e data ultima atualizacao) na pagina
  line_page_info=0;line_package_info_value="";line_project_info_value="";package_info=""

  #Arquivos temporariosutilizados na compilacao
  remove_temp_files
  create_temp_files

  #Variaveis usadas na compilacao
  compile_tag=0
  #String utilizada para armazenar os links da sidebar
  sidebar_links="<!--sidebar-->"
  #arquivos de importacao
  import=0;import_number=0
  #variavies de seccao
  section=0;section_number=0;section_line_open=0;section_file_open="";
  #variavies de subseccao
  subsection=0;subsection_number=0;subsection_line_open=0;subsection_file_open=""
  #variavies de callout
  callout=0;callout_number=0;callout_line_open=0;callout_file_open="";
  #variaveis para compilacao dos texts
  text=0;text_line_open=0;text_file_open=""
  #variaveis para compilacao footer
  footer=0;footer_number=0;footer_line_open=0;footer_file_open="";
  #variaveis para gallery
  gallery=0;gallery_number=0;gallery_line_open=0;gallery_file_open="";gallery_name="";gallery_columns=2;gallery_images=""
  #variaveis para blocos de codigo
  code_block=0;code_block_number=0;code_block_line_open=0;code_block_file_open="";code_git_file=0;code_line=0;
  #variaveis componente imagem
  image_line_open=0;image_file_open="";
  #variaveis component video
  video_line_open=0;video_file_open=""  
  #mensagens de log antes de configura variavel
  msg_log_before_check_var=""
}

function create_line_info_package(){
  line_package_info_value="<span class='docs-time'>"

  if [ -n "$docVersion" ] ; then
    line_package_info_value="$line_package_info_value $doc_version_package <strong>$docVersion</strong>"
  fi

  if [ -n "$occupation" ] ; then
    author_occupation="$occupation"
  fi

  if [ -n "$email" ] ; then
    author_email=", email: $email"
  fi


  if [ -n "$author" ] ; then
    line_package_info_value="$line_package_info_value $name_author_package <a title='${author_occupation} ${author_email} '><strong>$author</strong></a>"
  fi

  line_package_info_value="$line_package_info_value $last_update_package <strong>{{last_update}}</strong></span>"

}

function create_line_info_project(){
  if [ -n "$owner" ] ; then
    line_project_info_value="Owner(s): <strong>"$owner"</strong><br>"
  fi

  if [ -n "$create_date_project" ] ; then  
    line_project_info_value="$line_project_info_value $created_in: <strong>"$create_date_project"</strong>"
  fi
}

function begin_file_html(){
  echo -e "<!DOCTYPE html>\n<html>" > "$1"
}

function body_file_html(){
  echo -e "<body>" >> "$1"
}

function end_file_html(){
  echo -e "</body>\n</html>" >> "$1"
}

function page_body_with_sidebar_begin(){
  #tags com as classes referente a página de dodumentação
  echo -e '<div class="docs-content">\n<div class="container">' >> "$1"
}

function page_body_with_sidebar_end(){
  #fechar as tags com as classes referente a página de documentação
  echo -e "</div>\n</div>" >> "$1"
}

function compile_sidebar(){
  $(sed -i "s|{{sidebar_links}}|$sidebar_links|g" $package_temp_file )
}

function compile_head_package(){ 
  copy_package_component head "$package_temp_file"
  $(sed -i "s|{{package_name}}|$package_name|g" $package_temp_file )
  $(sed -i "s|{{author}}|$author|g" $package_temp_file )
  $(sed -i "s/{{color}}/$colorTheme/g" $package_temp_file )
}

function compile_head_project(){
  copy_project_component head "$1"
  $(sed -i "s|{{project_name}}|$project_name|g" "$1" )
  $(sed -i "s|{{owner}}|$owner|g" "$1" )
}

function compile_head_links_project(){
  copy_project_component head "$1"
  $(sed -i "s|{{project_name}}|$project_name Links|g" "$1" )
  $(sed -i "s|{{owner}}|$owner|g" "$1" )
}

function compile_header_package(){
  copy_package_component header "$package_temp_file"
  $(sed -i "s|{{package_name}}|$package_name|g" $package_temp_file )
  $(sed -i "s|{{project_name}}|$project_name|g" $package_temp_file )
  $(sed -i "s/{{color}}/$colorTheme/g" $package_temp_file )  
}

function compile_header_project(){
  copy_project_component header "$1"
  $(sed -i "s|{{project_name}}|$project_name|g" "$1" )
}

function open_info_and_body_cards_page(){
    echo -e '<div class="page-content">\n<div class="container">\n<div class="docs-overview py-5">\n<div class="row justify-content-left">' >> "$1"
}

function close_info_and_body_cards_page(){
    echo -e '</div>\n</div>\n</div>\n</div>' >> "$1"     
}

function compile_info_project(){
  text_info_project=$(echo -e $line_project_info_value)
  copy_project_component info $project_temp_file
  $(sed -i "s|{{documentation}}|$documentation|g" $project_temp_file )
  $(sed -i "s|{{text_info_project}}|$text_info_project|g" $project_temp_file )
}

function compile_footer_project(){
  copy_project_component footer "$project_temp_file"
  $(sed -i "s|{{project_name}}|$project_name|g" "$project_temp_file" )
}

function compile_image_component(){
  line_info_img=$(echo "$1" | sed 's/@img(//g' | sed 's/)//g')
  if [ -z $line_info_img  2> /dev/null ] ; then
    print_message "$error" "$tag_img_empty => $line $image_line_open $at $image_file_open "
    exit_with_error
  fi
  number_char=$(expr length $(echo "$line_info_img" | sed "s/ //g") - length `echo $(echo "$line_info_img" | sed "s/ //g") | sed "s/,//g"`)
  tags=$(expr $number_char + 1)

  img_size=12
  img_alt=""
  img_title=""
  for((c=1; c <=$tags; c++))
  {
    tag_name=$(echo "$line_info_img" | cut -d, -f $c | cut -d= -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
    tag_value=$(echo "$line_info_img" | cut -d, -f $c | cut -d= -f1 --complement -s) 
    case $tag_name in
      title)
        img_title="$tag_value"
      ;;
      src)
        img_source="$tag_value"      
      ;;      
      src_ext)
        img_source_ext="$tag_value"
      ;;
      grid_size)
        img_size="$tag_value"
      ;;
      alt)
        img_alt="$tag_value"
      ;;
      *)
        print_message $error "compiler: '$tag_name=' $tag_name_unknow => $line $image_line_open $at $image_file_open"
        exit_with_error
      ;;
    esac    
  }

  img_size=$(echo "$img_size" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  case "$img_size" in
    12|10|8|6|4|3);;
    *)
      print_message $error "$unknow_value_from_image_size => $line $image_line_open $at $image_file_open"
      exit_with_error
    ;;
  esac

  if [ -z "$img_source" ] && [ -z "$img_source_ext" ] ; then
    print_message $error "$tag_source_not_found @img() => $line $image_line_open $at $image_file_open"
    exit_with_error
  fi

  if [ -z $img_source_ext ] ; then
    check_file_exist "$img_source" $image_line_open "$image_file_open"
    img_path="$public_files_dir/$img_source"
  else
    check_ext_file_exist "$img_source_ext" $image_line_open "$image_file_open" "@img()"
    img_path="$img_source_ext"
  fi

  #Gerar componente imagem
  copy_package_component image "$section_sub_temp_file"
  $(sed -i "s|{{img_title}}|$img_title|g" $section_sub_temp_file )
  $(sed -i "s|{{img_alt}}|$img_alt|g" $section_sub_temp_file )
  $(sed -i "s|{{img_grid_size}}|$img_size|g" $section_sub_temp_file )
  $(sed -i "s|{{img_source}}|$img_path|g" $section_sub_temp_file )
   
}

function compile_video_component(){
  line_info_video=$(echo "$1" | sed 's/@video(//g' | sed 's/)//g')
  if [ -z $line_info_video  2> /dev/null ] ; then
    print_message "$error" "$tag_video_empty => $line $video_line_open $at $video_file_open "
    exit_with_error
  fi

  number_char=$(expr length $(echo "$line_info_video" | sed "s/ //g") - length `echo $(echo "$line_info_video" | sed "s/ //g") | sed "s/,//g"`)
  tags=$(expr $number_char + 1)

  video_size=12
  video_title=""
  for((c=1; c <=$tags; c++))
  {
    tag_name=$(echo "$line_info_video" | cut -d, -f $c | cut -d= -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
    tag_value=$(echo "$line_info_video" | cut -d, -f $c | cut -d= -f1 --complement -s) 
    case $tag_name in
      title)
        video_title="$tag_value"
      ;;
      src)
        video_source="$tag_value"      
      ;;      
      src_ext)
        video_source_ext="$tag_value"
      ;;
      grid_size)
        video_size="$tag_value"
      ;;
      *)
        print_message $error "compiler: '$tag_name=' $tag_name_unknow => $line $video_line_open $at $video_file_open"
        exit_with_error
      ;;
    esac    
  }

  video_size=$(echo "$video_size" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  case "$video_size" in
    12|6|4);;
    *)
      print_message $error "$unknow_value_from_video_size => $line $video_line_open $at $video_file_open"
      exit_with_error
    ;;
  esac

  if [ -z "$video_source" ] && [ -z "$video_source_ext" ] ; then
    print_message $error "$tag_source_not_found @video() => $line $video_line_open $at $video_file_open"
    exit_with_error
  fi

  if [ -z $video_source_ext ] ; then
    check_file_exist "$video_source" $video_line_open "$video_file_open"
    video_path="$public_files_dir/$video_source"
  else
    check_ext_file_exist "$video_source_ext" $video_line_open "$video_file_open" "@video()"
    video_path="$video_source_ext"
  fi

  #Gerar componente imagem
  copy_package_component video "$section_sub_temp_file"
  $(sed -i "s|{{video_title}}|$video_title|g" $section_sub_temp_file )
  $(sed -i "s|{{video_grid_size}}|$video_size|g" $section_sub_temp_file )
  $(sed -i "s|{{video_source}}|$video_path|g" $section_sub_temp_file )

}

function compile_section(){
  line_info_section=$(echo "$1" | sed 's/@(//g' | sed 's/)//g')
  number_line_info_section=$2
  number_char=$(expr length $(echo "$line_info_section" | sed "s/ //g") - length `echo $(echo "$line_info_section" | sed "s/ //g") | sed "s/,//g"`)
  tags=$(expr $number_char + 1)

  #variaveis para criacao da seccao
  section_icon=""
  section_badge_type=""
  section_badge_value=""

  for((s=1; s <=$tags; s++))
  {    
    tag_name=$(echo "$line_info_section" | cut -d, -f $s | cut -d= -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
    tag_value=$(echo "$line_info_section" | cut -d, -f $s | cut -d= -f1 --complement -s)  
    
    if [ -n "$tag_name" ] ; then 
      #verifica tags e values
      case $tag_name in
        name)
          section_name="$tag_value"
        ;;
        icon)
          section_icon="$tag_value"
        ;;
        bdg_type)
          check_default_types $tag_value
          retval=$?
          if [ "$retval" == 0 ] ; then
            section_badge_type="primary"
            print_message $warning "compiler: '$tag_value' => $color_unknow_set_default => $line $number_line_info_section $em $section_file_open"
          else
            section_badge_type=$tag_value
          fi
        ;;
        bdg_value)
          section_badge_value="$tag_value"
        ;;
        *)
          print_message $error "compiler: '$tag_name=' $tag_name_unknow => $line $number_line_info_section $at $section_file_open"
          exit_with_error
        ;;
      esac
      
    fi    
  } 

  if [ -n "$section_badge_type" ] && [ -z "$section_badge_value" ] ; then
    #erro existe tipo de bdg mais não seu value
    print_message $error "compiler: 'bdg_value' => $badge_value_missing => $line $number_line_info_section $at $section_file_open"
    exit_with_error
  fi

  if [ -z "$section_badge_type" ] && [ -n "$section_badge_value" ] ; then
    #existe o bdg e value, mas não o type, então set default primary
    section_badge_type="primary"    
  fi

  if [ -n "$section_badge_type" ] && [ -n "$section_badge_value" ] ; then
    badge=$(cat $HOME/.gdoc/package_components_files/badge | sed "s/{{badge_type}}/$section_badge_type/g" | sed "s/{{badge_name}}/$section_badge_value/g")
  else
    badge=""
  fi

  if [ $line_page_info -eq 0 ] ; then
    session_info_line=$line_package_info_value
    line_page_info=1
  else
    session_info_line=""
  fi

  #gerar linha da secção para o sidebar
  sidebar_links="$sidebar_links\n<li class='nav-item section-title'><a class='nav-link scrollto active' href='#section-$section_number'>"
  if [ -n "$section_icon" ] ; then
    sidebar_links="$sidebar_links <span class='theme-icon-holder me-2'><i class='$section_icon'></i></span>$section_name</a></li>"
  else
    sidebar_links="$sidebar_links $section_name</a></li>"
  fi
  
  # abrir secção
  copy_package_component section_open "$section_sub_temp_file"
  $(sed -i "s/{{section_id}}/$section_number/g" $section_sub_temp_file )
  $(sed -i "s|{{session_name}}|$section_name|g" $section_sub_temp_file )
  $(sed -i "s|{{section_badge}}|$badge|g" $section_sub_temp_file )
  $(sed -i "s|{{package_info}}|$session_info_line|g" $section_sub_temp_file )

  #Cria link para seccao se ativado
  generate_link s "$section_name" $section_number
}

function compile_subsection(){
  line_info_subsection=$(echo "$1" | sed 's/@(//g' | sed 's/)//g')
  number_line_info_subsection=$2
  number_char=$(expr length $(echo "$line_info_subsection" | sed "s/ //g") - length `echo $(echo "$line_info_subsection" | sed "s/ //g") | sed "s/,//g"`)
  tags=$(expr $number_char + 1)

  #variaveis para criação da subsecção
  subsection_icon=""
  subsection_badge_type=""
  subsection_badge_value=""

  for((ss=1; ss <=$tags; ss++))
  {    
    tag_name=$(echo "$line_info_subsection" | cut -d, -f $ss | cut -d= -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
    tag_value=$(echo "$line_info_subsection" | cut -d, -f $ss | cut -d= -f1 --complement -s)  
    
    if [ -n "$tag_name" ] ; then 
      #verifica tags e values
      case $tag_name in
        name)
          subsection_name="$tag_value"
        ;;        
        bdg_type)         
          check_default_types $tag_value
          retval=$?
          if [ "$retval" == 0 ] ; then
            subsection_badge_type="primary"
            print_message $warning "compiler: '$tag_value' => $color_unknow_set_default"
            print_message $warning "compiler: tag bdg_type '$tag_value' => $line $number_line_info_subsection $at $subsection_file_open"            
          else          
            subsection_badge_type="$tag_value"
          fi
        ;;
        bdg_value)
          subsection_badge_value="$tag_value"
        ;;
        *)
          print_message $error "compiler: '$tag_name=' $tag_name_unknow => $line $number_line_info_subsection $at $subsection_file_open"
          exit_with_error
        ;;
      esac
      
    fi    
  } 

  if [ -n "$subsection_badge_type" ] && [ -z "$subsection_badge_value" ] ; then
    #erro existe tipo de bdg mais não seu value
    print_message $error "compiler: 'bdg_value' => $badge_value_missing => $line $number_line_info_subsection $at $subsection_file_open"
    exit_with_error
  fi
  
  if [ -z "$subsection_badge_type" ] && [ -n "$subsection_badge_value" ] ; then
    #existe o bdg e value, mas não o type, então set default primary
    subsection_badge_type="primary"
  fi

  if [ -n "$subsection_badge_type" ] && [ -n "$subsection_badge_value" ] ; then
    sub_badge=$(cat $HOME/.gdoc/package_components_files/badge | sed "s/{{badge_type}}/$subsection_badge_type/g" | sed "s/{{badge_name}}/$subsection_badge_value/g")
  else
    sub_badge=""
  fi

  #gerar linha da secção para o sidebar
  sidebar_links="$sidebar_links\n<li class='nav-item'><a class='nav-link scrollto subsession' href='#subsection-$subsection_number'>$subsection_name</a></li>"
  
  # abrir secção
  copy_package_component subsection_open "$section_sub_temp_file"
  $(sed -i "s/{{subsection_id}}/$subsection_number/g" $section_sub_temp_file )
  $(sed -i "s|{{subsession_name}}|$subsection_name|g" $section_sub_temp_file )
  $(sed -i "s|{{subsection_badge}}|$sub_badge|g" $section_sub_temp_file )

  #Cria link para seccao se ativado
  generate_link ss "$subsection_name" $subsection_number

}

function compile_callout(){
  line_info_callout=$(echo "$1" | sed 's/@(//g' | sed 's/)//g')
  number_line_info_callout=$2
  number_char=$(expr length $(echo "$line_info_callout" | sed "s/ //g") - length `echo $(echo "$line_info_callout" | sed "s/ //g") | sed "s/,//g"`)
  tags=$(expr $number_char + 1)

  #variaveis para criação da subsecção
  callout_icon=""

  for((c=1; c <=$tags; c++))
  {
    tag_name=$(echo "$line_info_callout" | cut -d, -f $c | cut -d= -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
    tag_value=$(echo "$line_info_callout" | cut -d, -f $c | cut -d= -f1 --complement -s) 
    case $tag_name in
      name)
        callout_name="$tag_value"
      ;;
      icon)
        callout_icon="$tag_value"
      ;;
      type)  
        tag_value=$(echo "$tag_value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        check_default_types_callout "$tag_value"
          retval=$?
          if [ "$retval" == 0 ] ; then
            callout_type="info" #default
            print_message $warning "compiler: '$tag_value' => $callout_type_unknow_set_default => $line $number_line_info_callout $at $callout_file_open"
          else
            callout_type="$tag_value"
          fi
      ;;
      *)
        print_message $error "compiler: '$tag_name=' $tag_name_unknow => $line $number_line_info_callout $at $callout_file_open"
        exit_with_error
      ;;
    esac    
  }

  test_calout=$(echo $callout_type | grep ^block-)
  if [ -z $test_calout ] ; then
  copy_package_component callout_open "$section_sub_temp_file"
  else
    copy_package_component callout-block_open "$section_sub_temp_file"
  fi

  #replace conteudo do info callout
  $(sed -i "s/{{callout_type}}/$callout_type/g" $section_sub_temp_file )
  $(sed -i "s|{{callout_icon}}|$callout_icon|g" $section_sub_temp_file )
  $(sed -i "s|{{callout_name}}|$callout_name|g" $section_sub_temp_file )
}

function compile_code_block(){
  line_info_code_block=$(echo "$1" | sed 's/@(//g' | sed 's/)//g')
  number_line_info_code_block=$2
  number_char=$(expr length $(echo "$line_info_code_block" | sed "s/ //g") - length `echo $(echo "$line_info_code_block" | sed "s/ //g") | sed "s/,//g"`)
  tags=$(expr $number_char + 1)

  code_block_title=""
  code_block_language=""
  code_block_git_file=""

  for((c=1; c <=$tags; c++))
  {
    tag_name=$(echo "$line_info_code_block" | cut -d, -f $c | cut -d= -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
    tag_value=$(echo "$line_info_code_block" | cut -d, -f $c | cut -d= -f1 --complement -s) 
    case $tag_name in
      title)
        code_block_title="$tag_value"      
      ;;
      language)
        check_default_types_languages $tag_value
          retval=$?
          if [ "$retval" == 0 ] ; then
            print_message $error "compiler: '$tag_value' => $code_block_language_unknow => $line $number_line_info_code_block $at $code_block_file_open"
            print_message "" "compiler: $available_languages_values 'css','git','javascript','handlebars','http','markup','php','python','ruby','vim','yaml'"
            exit_with_error
          else
            code_block_language=$tag_value
          fi
      ;;
      git_file)
        code_block_git_file="$tag_value"
      ;;
      *)
        print_message $error "compiler: '$tag_name=' $tag_name_unknow => $line $number_line_info_code_block $at $code_block_file_open"
        exit_with_error
      ;;
    esac    
  }

  if [ -z $code_block_language ] ; then
    code_git_file=1
    echo "<h5>$code_block_title</h5><script src='$code_block_git_file'></script>" >> $section_sub_temp_file    
  else
    copy_package_component code_block_open "$section_sub_temp_file"
    $(sed -i "s|{{code_block_title}}|$code_block_title|g" $section_sub_temp_file )
    $(sed -i "s|{{code_block_language}}|$code_block_language|g" $section_sub_temp_file )
  fi
  
}

function compile_gallery(){
  line_info_gallery=$1
  line_number_gallery=$2
  if [ -n "$line_info_gallery" ] ; then
    line_info_gallery=$(echo "$line_info_gallery" | sed 's/@(//g' | sed 's/)//g')
    number_char=$(expr length $(echo "$line_info_gallery" | sed "s/ //g") - length `echo $(echo "$line_info_gallery" | sed "s/ //g") | sed "s/,//g"`)
    tags=$(expr $number_char + 1)

    for((g=1; g <=$tags; g++))
    {
      tag_name=$(echo "$line_info_gallery" | cut -d, -f $g | cut -d= -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
      tag_value=$(echo "$line_info_gallery" | cut -d, -f $g | cut -d= -f1 --complement -s) 
      case $tag_name in
        columns)
          gallery_columns="$tag_value"
        ;;
        name)
          gallery_name="$tag_value"
        ;;
        *)
          print_message $error "compiler: '$tag_name=' $tag_name_unknow => $line $line_number_gallery $at $gallery_file_open"
          exit_with_error
        ;;
      esac
    }
    #Verifica se o valor configurado eh um dos valores existentes
    gallery_columns=$(echo "$gallery_columns" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
    case $gallery_columns in
      2|3|4);;
      *)
        print_message $error "$unknow_value_from_gallery_columns => $line $line_number_gallery $at $gallery_file_open"
        exit_with_error
      ;;
    esac
  fi
  copy_package_component gallery "$section_sub_temp_file"
  $(sed -i "s|{{gallery_name}}|$gallery_name|g" $section_sub_temp_file )

}

function compile_gallery_image(){
  line_number_img_info=$2
  line_img_info_gallery=$(echo "$1" | sed 's/@img_gallery(//g' | sed 's/)//g')
  if [ -z $line_number_img_info  2> /dev/null ] ; then
    print_message "$error" "$tag_img_empty => $line $image_line_open $at $image_file_open "
    exit_with_error
  fi
  number_char=$(expr length $(echo "$line_img_info_gallery" | sed "s/ //g") - length `echo $(echo "$line_img_info_gallery" | sed "s/ //g") | sed "s/,//g"`)
  tags=$(expr $number_char + 1)

  gallery_img_title=""
  gallery_img_source=""
  gallery_img_source_ext=""
  gallery_img_alt=""

  for((gi=1; gi <=$tags; gi++))
  {
    tag_name=$(echo "$line_img_info_gallery" | cut -d, -f $gi | cut -d= -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  
    tag_value=$(echo "$line_img_info_gallery" | cut -d, -f $gi | cut -d= -f1 --complement -s) 
    case $tag_name in
      title)
        gallery_img_title="$tag_value"
      ;;
      src)
        gallery_img_source="$tag_value"
      ;;
      src_ext)
        gallery_img_source_ext="$tag_value"
      ;;      
      alt)
        gallery_img_alt="$tag_value"
      ;;
      *)
        print_message $error "compiler: '$tag_name=' $tag_name_unknow => $line $line_number_img_info $at $gallery_file_open"
        exit_with_error
      ;;
    esac
  }

  #Verificacoes das tags obrigatorias da imagem da galeria
  if [ -z "$gallery_img_source" ] && [ -z "$gallery_img_source_ext" ] ; then
    print_message $error "$tag_source_not_found @img_gallery() => $line $line_number_img_info $at $gallery_file_open"
    exit_with_error
  fi

  if [ -z "$gallery_img_source_ext" ] ; then
    check_file_exist "$gallery_img_source" $line_number_img_info "$gallery_file_open"
    img_gallery_path="$public_files_dir/$gallery_img_source"
  else
    check_ext_file_exist "$gallery_img_source_ext" $line_number_img_info "$gallery_file_open" "@img_gallery()"
    img_gallery_path="$gallery_img_source_ext"
  fi

  #Adicionar a imagem em gallery_images
  gallery_columns_value=$((12/$gallery_columns))
  gallery_images="$gallery_images\n<div class='col-12 col-md-$gallery_columns_value mb-3'>"
  gallery_images="$gallery_images\n<h4>$gallery_img_title</h4>"
  gallery_images="$gallery_images\n<a href='$img_gallery_path'><img class='figure-img img-fluid shadow rounded' src='$img_gallery_path' alt='$gallery_img_alt' title='$gallery_img_title'/></a>"
  gallery_images="$gallery_images\n</div>"
}

function compile_package_card(){
  copy_project_component package_card "$project_temp_file"
  num_columns=$((12/num_columns_cards))
  $(sed -i "s|{{num_columns_cards}}|$num_columns|g" $project_temp_file )
  $(sed -i "s|{{colorTheme}}|$colorTheme|g" $project_temp_file )

  if [ -z "$package_card_icon" ] ; then
    package_card_icon="fas fas fa-laptop-code" #default icon
  fi

  $(sed -i "s|{{package_card_icon}}|$package_card_icon|g" $project_temp_file )
  $(sed -i "s|{{package_name}}|$package_name|g" $project_temp_file )
  $(sed -i "s|{{package_description}}|$package_description|g" $project_temp_file )
  $(sed -i "s|{{package_info}}|$package_info|g" $project_temp_file )
  package_path_index_file="packages/$package_name_no_space.html"
  $(sed -i "s|{{package_path_index_file}}|$package_path_index_file|g" $project_temp_file )
  
  #limpar as informacoes do package para buscar do proximo
  package_info=""
}

##### FIM FUNCOES COMPILAR COMPONENTES #####

function set_config_variables_package(){
  print_message_compile=$1
  config_file="$package_dir_name/package.conf"
  
  if [ -e "$config_file" ] ; then
    #configurar geracao do arquivo e msgs de log
    generate_log=$(cat "$config_file" | grep generate_log= | cut -d= -f2 )
    if [ "$generate_log" == "true" ] ; then
      file_log="../../logs/Project_$project_name.log"
      if [ ! -e "$file_log" ] ; then
        touch $file_log
      fi
      echo -e $msg_log_before_check_var >> $file_log
    fi

    if [ "$print_message_compile" == "true" ] ; then
      print_message "$ok" "compiler: $package_conf_file_found"
    fi

    #Checando nome do package
    package_name=$(cat "$config_file" | grep package_name= | cut -d= -f2 )
    if [ -z "$package_name" ] ; then
      print_message $warning "$package_name_missing_in_package_conf"
      package_name="Package Name"
      package_name_no_space="Package_Name"
    else
      package_name_no_space=$(echo "$package_name" | sed 's/ /_/g')
    fi

    #Checando nome do projeto
    if [ -z "$project_name" ] ; then
      print_message $warning "$project_name_missing_in_package_conf"
      project_name="Project Name"
    fi

    #Checando cor do tema do package
    colorTheme=$(cat "$config_file" | grep colorTheme= | cut -d= -f2 )
    if [ -z $colorTheme ] ; then
      print_message $warning "$package_colorTheme_missing_in_package_conf"
      colorTheme="purple"  
    else
      case $colorTheme in
        blue);;gray);;green);;orange);;pink);;purple);;red);;yellow);;
        *)
        print_message $warning "$colorTheme => $package_colorTheme_unknow_in_package_conf"
        colorTheme="purple"
        ;;
      esac
    fi
    author=$(cat "$config_file" | grep author= | cut -d= -f2 )
    occupation=$(cat "$config_file" | grep occupation= | cut -d= -f2 )
    email=$(cat "$config_file" | grep email= | cut -d= -f2 )
    docVersion=$(cat "$config_file" | grep docVersion= | cut -d= -f2 )
    lastUpdate=$(cat "$config_file" | grep lastUpdate= | cut -d= -f2 )
    package_card_icon=$(cat "$config_file" | grep card_icon= | cut -d= -f2 )
    package_description=$(cat "$config_file" | grep description= | cut -d= -f2 )
  else
    print_message $error "$package_conf_file_not_found"
    exit_with_error
  fi
}

function compile_gdoc_to_html(){
  config_file="$1"
  import_file="$2"
  line_import="$3"
  file_line_import="$4" 

  number_line=0

  #verifica e seta qual arquivo deve ser compilado
  if [ -z "$import_file" ] ; then
    compile_file="$config_file"
  else
    if [ -e "$import_file" ] ; then
      compile_file="$import_file"
    else
      print_message $error "$compile_not_possible => '$import_file' $import_file_not_found => $line $line_import $at $file_line_import"
      exit_with_error
    fi 
  fi

  #testar ultima linha => erro de nao reconhecimento ultima linha
  check_last_line "$compile_file"

  while IFS= read -r read_line || [[ -n "$read_line" ]]; do
    number_line=$((number_line+1))
    component_tag=$(echo "$read_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    if [ "$component_tag" == 'compile{' ] ; then
      compile_tag=1      
    elif [ "$component_tag" == '}compile' ] ; then
      compile_tag=0
    elif [ $compile_tag -eq 1 ] ; then
      ##### IGNORAR LINHA DE COMENTARIO #####
      comentario=$(echo "$component_tag" | grep -v ^"#")
      if [ -n "$comentario" ] ; then
        ##### VERIFICAR TAG DE INFO ######
        tag_info=$(grep -v "@(" <<<"$read_line")
        if [ -n "$tag_info" ] ; then
          ##### CHECK IMPORT #####
          import_name=$(grep import= <<<"$read_line")
          import_public_name=$(grep import_public= <<<"$read_line")
          if [ -n "$import_name" ] || [ -n "$import_public_name" ] ; then
            if [ $import -eq 1 ] ; then
              print_message $error "$import_inside_import_file => $line $number_line $at $compile_file"
              exit_with_error
            else
              import=1
              import_number=$((import_number+1))
              import_file_name=$(echo $read_line | cut -d= -f2)
              #salvo em qual linha parou a execucaoo e qual arquivo para quando voltar e execucao
              number_line_back_file=$number_line
              compile_back_file="$compile_file"
              #faz a chamada recursivamente:
              if [ -n "$import_name" ] ; then            
                compile_gdoc_to_html "$config_file" "$package_dir_name/gdocs/$import_file_name" $number_line "$compile_file" 2> /dev/null
              else
                compile_gdoc_to_html "$config_file" "public_gdocs/$import_file_name" $number_line "$compile_file" 2> /dev/null
              fi
            fi
          else
            #componente image e video. image gallerys
            img_component=$(grep "@img(" <<<"$read_line")
            video_component=$(grep "@video(" <<<"$read_line")
            img_gallery_tag=$(grep "@img_gallery(" <<<"$read_line")
            if [ -n "$img_component" ] ; then
              image_line_open=$number_line
              image_file_open="$compile_file"
              compile_image_component "$read_line"
            elif [ -n "$video_component" ] ; then
              video_line_open=$number_line
              video_file_open="$compile_file"
              compile_video_component "$read_line"
            elif [ -n "$img_gallery_tag" ] ; then
              compile_gallery_image "$component_tag" $number_line
            else
              ##### VERIFICA COMPONENTES ######            
              case $component_tag in
                "s{"|"section{")
                  if [ $section -eq 0 ] ; then
                    section=1
                    section_number=$((section_number+1))
                    section_line_open=$number_line
                    section_file_open="$compile_file"

                    #primeiro: buscar as informações da secção (number_line+1), se não existir sair com erro
                    number_section_info_line=$((number_line+1))
                    line_info_section=$(sed -n ${number_section_info_line}p "$compile_file")
                    #faz a checagem da estrutura da linha de informações e compila a secção
                    check_line_info "$line_info_section" $number_section_info_line "$section_file_open"
                    compile_section "$line_info_section" $number_section_info_line
                  else
                    print_message $error "$error_open_section_inside_section"
                    print_message "" "compiler: $section_error_open $line $number_line $at $compile_file"
                    print_message "" "compiler: $section_not_close $line $section_line_open $at $section_file_open"
                    exit_with_error
                  fi
                ;;
                "}s"|"}section")
                  if [ $section -eq 0 ] ; then
                    print_message $error "$error_close_section_not_exists => $line $number_line $at $compile_file"
                    exit_with_error
                  else
                    #fim de uma secção
                    #mensagem de finalização da secção encontrada
                    if [ "$section_file_open" == "$compile_file" ] ; then
                      print_message "$ok" "compiler: $compile_close_section_found 'section-$section_number' [ $line $section_line_open => $line $number_line ] $at $compile_file"
                    else
                      print_message "$ok" "compiler: $compile_close_section_found 'section-$section_number' [ $line $section_line_open $at $section_file_open => $line $number_line $at $compile_file ]"                
                    fi
                    section=0
                    section_line_open=0
                    section_file_open=""
                    #fechar secção
                    copy_package_component "section_close" "$section_sub_temp_file"
                  fi
                ;;
                "ss{"|"subsection{")
                  if [ $subsection -eq 0 ] ; then
                    subsection_number=$((subsection_number+1))
                    subsection=1
                    subsection_line_open=$number_line
                    subsection_file_open="$compile_file"

                    #primeiro: buscar as informações da subsecção (number_line+1), se não existir sair com erro
                    number_subsection_info_line=$((number_line+1))
                    line_info_subsection=$(sed -n ${number_subsection_info_line}p "$compile_file")                    
                    #faz a checagem da estrutura da linha de informações e compila a subsecção
                    check_line_info "$line_info_subsection" $number_subsection_info_line "$subsection_file_open"
                    compile_subsection "$line_info_subsection" $number_subsection_info_line
                  else
                    print_message $error "$error_open_subsection_inside_subsection"
                    print_message "" "compiler: $subsection_error_open $line $number_line $at $compile_file"
                    print_message "" "compiler: $subsection_not_close $line $subsection_line_open $at $subsection_file_open"
                    exit_with_error
                  fi
                ;;
                "}ss"|"}subsection")
                  if [ $subsection -eq 0 ] ; then
                    print_message $error "$error_close_subsection_not_exists => $line $number_line $at $compile_file"
                    exit_with_error
                  else
                    #mensagem de finalização da subsecção encontrada
                    if [ "$subsection_file_open" == "$compile_file" ] ; then
                      print_message "$ok" "compiler: $compile_close_subsection_found 'subsection-$subsection_number' [ $line $subsection_line_open => $line $number_line ] $at $compile_file"
                    else
                      print_message "$ok" "compiler: $compile_close_subsection_found 'subsection-$subsection_number' [ $line $subsection_line_open $at $subsection_file_open => $line $number_line $at $compile_file ]"                
                    fi
                    
                    subsection=0
                    subsection_line_open=0
                    subsection_file_open=""
                    #fechar subsecção
                    copy_package_component subsection_close "$section_sub_temp_file"
                  fi
                ;;
                "t{"|"text{")
                  if [ $text -eq 0 ] ; then
                    text=1
                    text_line_open=$number_line
                    text_open_file="$compile_file"
                    echo -e "<p class='text-default'>" >> $section_sub_temp_file
                  else
                    print_message $error "$error_open_tag_text => $line $number_line $at $config_file"
                    print_message "" "compiler: $already_exist_open_text_tag => $line $text_line_open $at $text_open_file"
                    exit_with_error
                  fi
                ;;
                "}t"|"}text")
                  if [ $text -eq 0 ] ; then
                    print_message $error "$error_close_text_not_exists => $line $number_line $at $compile_file"
                    exit_with_error
                  else
                    text=0
                    text_line_open=0
                    text_file_open=""
                    echo -e "</p><br>" >> $section_sub_temp_file
                  fi
                ;;
                "cl{"|"callout{")
                  if [ $callout -eq 0 ] ; then
                    callout=1
                    callout_number=$((callout_number+1))
                    callout_line_open=$number_line
                    callout_file_open="$compile_file"

                    #inciar a compilacao do callout
                    number_callout_info_line=$((number_line+1))
                    line_info_callout=$(sed -n ${number_callout_info_line}p "$compile_file")
                    #faz a checagem da estrutura da linha de informacoes e compila o callout
                    check_line_info "$line_info_callout" $number_callout_info_line $callout_file_open
                    compile_callout "$line_info_callout" $number_callout_info_line
                  else
                    print_message $error "$error_open_callout" 
                    print_message "" "compiler: $callout_error_open => $line $number_line $at $compile_file"
                    print_message "" "compiler: $callout_not_close => $line $callout_line_open $at $callout_file_open"
                    exit_with_error
                  fi
                ;;
                "}cl"|"}callout")
                  if [ $callout -eq 0 ] ; then
                    print_message $error "$error_close_callout_not_exists => $line $number_line $at $compile_file"
                    exit_with_error
                  else
                    #mensagem de finalização do callout encontrado
                    if [ "$callout_file_open" == "$compile_file" ] ; then
                      print_message "$ok" "compiler: $compile_close_callout_found [ $line $callout_line_open => $line $number_line ] $at $compile_file"
                    else
                      print_message "$ok" "compiler: $compile_close_callout_found [ $line $callout_line_open $at $callout_file_open => $line $number_line $at $compile_file ]"                
                    fi              
                    callout=0
                    callout_line_open=0
                    callout_file_open=""
                    #fechar callout
                    copy_package_component callout_close "$section_sub_temp_file"
                  fi
                ;;
                "ft{"|"footer{")
                  if [ $footer -eq 0 ] ; then
                    footer=1                    
                    footer_number=$((footer_number+1))
                    if [ $footer_number -gt 1 ] ; then
                      print_message $warning "$already_exists_footer => $line $footer_line_open $at $footer_file_open"
                    else
                      footer_line_open=$number_line
                      footer_file_open="$compile_file"
                    fi
                    copy_package_component footer_open "$section_sub_temp_file"
                  else
                    print_message $error "$already_exists_footer => $line $footer_line_open $at $footer_file_open"
                    exit_with_error
                  fi
                ;;
                "}ft"|"}footer")
                  footer=0
                    if [ "$footer_file_open" == "$compile_file" ] ; then
                      print_message "$ok" "compiler: $footer_buit_sucessfully [ $line $footer_line_open => $line $number_line ] $at $compile_file"
                    else
                      print_message "$ok" "compiler: $footer_buit_sucessfully [ $line $footer_line_open $at $footer_file_open => $line $number_line $at $compile_file ]"                
                    fi 
                  #fechar o footer
                  copy_package_component footer_close "$section_sub_temp_file"
                ;;
                "code{")
                  if [ $code_block -eq 0 ] ; then
                    code_block=1
                    code_block_number=$((code_block_number+1))
                    code_block_line_open=$number_line
                    code_block_file_open="$compile_file"
                    code_line=1

                    #primeiro: buscar as informações da code block (number_line+1), se não existir sair com erro
                    number_code_block_info_line=$((number_line+1))
                    line_info_code_block=$(sed -n ${number_code_block_info_line}p "$compile_file")
                    #faz a checagem da estrutura da linha de informações e compila o bloco de codigo
                    check_line_info "$line_info_code_block" $number_code_block_info_line "$code_block_file_open"
                    compile_code_block "$line_info_code_block" $number_code_block_info_line
                  else
                    print_message $error "$error_open_code_inside_code"
                    print_message "" "compiler: $code_block_error_open $line $number_line $at $compile_file"
                    print_message "" "compiler: $code_block_not_close $line $code_block_line_open $at $code_block_file_open"
                    exit_with_error
                  fi
                ;;
                "}code")
                  if [ $code_block -eq 0 ] ; then
                    print_message $error "$error_close_code_block_not_exists => $line $number_line $at $compile_file"
                    exit_with_error
                  else
                    #mensagem de finalização do callout encontrado
                    if [ "$code_block_file_open" == "$compile_file" ] ; then
                      print_message "$ok" "compiler: $compile_close_code_block [ $line $code_block_line_open => $line $number_line ] $at $compile_file"
                    else
                      print_message "$ok" "compiler: $compile_close_code_block [ $line $code_block_line_open $at $code_block_file_open => $line $number_line $at $compile_file ]"                
                    fi              
                    code_block=0
                    code_block_line_open=0
                    code_block_file_open=""                    

                    if [ $code_git_file -eq 0 ] ; then
                      #fechar code block
                      #$(cat $HOME/.gdoc/package_components_files/code_block_close >> $section_sub_temp_file)
                      code_block_close_value=$(cat $HOME/.gdoc/package_components_files/code_block_close)
                      number_line_file_temp=$(wc -l "$section_sub_temp_file" | awk '{print $1}' )
                      $(sed -i "${number_line_file_temp}s|$|$code_block_close_value|" "$section_sub_temp_file")
                    else
                      code_git_file=0
                    fi
                  fi
                ;;
                "gl{"|"gallery{")
                  if [ $gallery -eq 0 ] ; then
                    gallery=1
                    gallery_number=$((gallery_number+1))
                    gallery_line_open=$number_line
                    gallery_file_open="$compile_file"
                    #buscar as informações do gallery (number_line+1), se não existir, definir coluna padrão
                    number_gallery_info_line=$((number_line+1))
                    line_info_gallery=$(sed -n ${number_gallery_info_line}p "$compile_file")
                    #info_gallery=$(grep '@(' <<<"$line_info_gallery")
                    info_gallery=$(grep '@(' <<<"$line_info_gallery")
                    if [ -n "$info_gallery" ] ; then
                      #faz a checagem da estrutura da linha de informações e compila a secção
                      check_line_info "$line_info_gallery" $number_gallery_info_line "$gallery_file_open"
                    else
                      line_info_gallery=""
                    fi
                    compile_gallery "$line_info_gallery" $number_gallery_info_line
                  else
                    print_message $error "$already_exist_gallery_tag_open"
                    print_message "" "compiler: $gallery_error_open $line $number_line $at $compile_file"
                    print_message "" "compiler: $gallery_not_close $line $gallery_line_open $at $gallery_file_open"
                    exit_with_error
                  fi
                ;;
                "}gl"|"}gallery")
                  if [ $gallery -eq 0 ] ; then
                    print_message $error "$error_close_gallery_not_exists => $line $number_line $at $compile_file"
                    exit_with_error
                  else
                    if [ -z "$gallery_images" ] ; then
                      print_message $error "$gallery_without_images"
                      print_message "" "compiler: $gallery_empty => $line $gallery_line_open $at $gallery_file_open"
                      exit_with_error
                    else  
                      #mensagem de finalização da galeria                    
                      if [ "$gallery_file_open" == "$compile_file" ] ; then
                        print_message "$ok" "compiler: $compile_close_gallery [ $line $gallery_line_open => $line $number_line ] $at $compile_file"
                      else
                        print_message "$ok" "compiler: $compile_close_gallery [ $line $gallery_line_open $at $gallery_file_open => $line $number_line $at $compile_file ]"                
                      fi
                      #close gallery
                      gallery=0
                      gallery_file_open=""
                      gallery_line_open=0
                      $(sed -i "s|{{gallery_images}}|$gallery_images|g" $section_sub_temp_file )
                      gallery_images=""
                    fi
                  fi
                ;;
                *)
                  #a linha atual nao eh um componente, entao envia seu conteudo direto para o arquivo section_sub_temp_file
                  #remove os espacos de inicio e fim da linha e passa para o arquivo
                  read_line=$(echo "$read_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') 
                  if [ $code_line -eq 1 ] ; then
                    #evitar linha desnecessário início e fim do bloco de codigo
                    number_line_file_temp=$(wc -l "$section_sub_temp_file" | awk '{print $1}' )
                    $(sed -i "${number_line_file_temp}s|$|$read_line|" "$section_sub_temp_file")
                    code_line=0
                  else
                    echo "$read_line" >> $section_sub_temp_file                
                  fi
                ;;
              esac
            fi
          fi #import
        fi #tag info
      fi #comentario
    fi

  done < "$compile_file"

  number_line=$number_line_back_file
  compile_file="$compile_back_file"

  if [ $import -eq 1 ] ; then
    import=0
  fi
}

function compile_packages_cards(){  
  if [ -n "$(ls -A packages/)" ]; then
    search_dir='packages'
    for package_path in "$search_dir"/*
    do
      package_dir_name=$package_path
      
      set_config_variables_package "$package_path"

      #gerar package_info customizado para card do package
      if [ -n "$docVersion" ] ; then
        package_info="$package_info $doc_version_package <strong>$docVersion</strong><br>"
      fi

      if [ -n "$author" ] ; then
        package_info="$package_info $name_author_package <strong>$author</strong><br>"
      fi

      if [ -n "$lastUpdate" ] ; then
        package_info="$package_info $last_update_package <strong>$lastUpdate</strong>"
      fi

      #compilar o card na pagina do projeto
      compile_package_card
    done
  fi  
}

function build_package_file_html(){
  #configura as variaveis do package utilizada para a construcao da pagina
  set_config_variables_package "true"

  #Gerar link para o package
  generate_link p "$package_name"
  #generate_link ss "Teste" 4

  ##### INICAR O PROCESSO DE CONSTRUCAO #####
  #gera variavel para insercao da linha de informacao do package na pagina
  create_line_info_package

  ##### INICIO COMPONENTES #####
  create_temp_files
  
  begin_file_html "$package_temp_file"

  #Testa se diretorio components package existe
  if [ ! -d "../../components/package" ] ; then
    print_message "$error" "$dir_package_components_missing"
    exit_with_error
  fi
  #componente head
  compile_head_package

  #body da pagina
  body_file_html "$package_temp_file"

  #componente header
  compile_header_package

  #Iniciar a compilacao dos componentes para html => tag compile{} do arquivo conf
  compile_gdoc_to_html "$package_dir_name/package.conf"

  #Verificar se foi fechadas todas as tags abertas dentro do compile{...}compile
  check_if_close_tags

  #Criar sidebar se necessario
  if [ "$sidebar_links" != "<!--sidebar-->" ] ; then  
    copy_package_component sidebar "$package_temp_file"
    compile_sidebar      
    print_message $ok "compiler: $sidebar_buit_sucessfully"
  fi

  #Apenas gerar arquivo html se estiver rodando sem a opecao --test
  if [ $test_option -eq 0 ] ; then
    #verifica se existe o diretorio do projeto e packages dentro do diretorio public
    if [ ! -d "../../../public/help/$project_name" ] ; then
      mkdir -pv "../../../public/help/$project_name"
    fi

    if [ ! -d "../../../public/help/$project_name/packages" ] ; then
      mkdir -pv "../../../public/help/$project_name/packages"
    fi

    package_index_file="../../../public/help/$project_name/packages/$package_name_no_space.html"
    
    if [ -e "$package_index_file" ] ; then      
      mv "$package_index_file" "../../logs/backups/backup_$package_name-$date.html"
    fi
    touch "$package_index_file"

    #Gerar o arquivo index
    $(cat "$package_temp_file" >> "$package_index_file")
    if [ "$sidebar_links" != "<!--sidebar-->" ] ; then
      page_body_with_sidebar_begin "$package_index_file"
      $(cat $section_sub_temp_file >> "$package_index_file")
      page_body_with_sidebar_end  "$package_index_file"      
    else
      $(echo '<div class="container">' >> "$package_index_file" )
      $(cat $section_sub_temp_file >> "$package_index_file")
      $(echo "</div>" >> "$package_index_file" )          
    fi

    copy_package_component "imports_js_end_page" "$package_index_file"
    #$(cat $HOME/.gdoc/package_components_files/imports_js_end_page >> "$package_index_file")
    

    #Finalizar arquivo
    end_file_html "$package_index_file"

    #Atualizar data de ultima atualizacao com a data de compilacao do package
    lastUpdate=$(cat "$config_file" | grep lastUpdate= | cut -d= -f2 )
    compile_date=$(date +"%d/%m/%Y %H:%M")
    $(sed -i "s|$lastUpdate|$compile_date|g" "$config_file")
    lastUpdate=$(cat "$config_file" | grep lastUpdate= | cut -d= -f2 )
    $(sed -i "s|{{last_update}}|$compile_date|g" "$package_index_file")
  fi

  #package compilado com sucesso
  print_info_built_package
  
  #limpar estado das variaveis para proximo package a ser compilado
  clear_variables_and_files
}

function build_project_file_html(){
  #busca as variaveis direto, porque ja foi verificado que o conf existe em check_before_compiler()
  owner=$(cat project.conf | grep owner= | cut -d= -f2 )
  create_date_project=$(cat project.conf | grep createDate= | cut -d= -f2 )
  num_columns_cards=$(cat project.conf | grep num_columns_cards= | cut -d= -f2 )

  #Verifica se o valor configurado para colunas dos cards eh um dos valores existentes
  case $num_columns_cards in
    2|3|4);;
    *)
      print_message $warning "$num_columns_cards => $unknow_value_from_package_cards_columns"
      num_columns_cards=2
    ;;
  esac

  if [ $test_option -eq 0 ] && [ $compile_package_errors -eq 0 ] ; then
    #Criar arquivo temporario
    touch "$project_temp_file"

    ##### INICIO COMPONENTES #####
    begin_file_html "$project_temp_file"

    #componente head
    compile_head_project "$project_temp_file"

    #body da pagina
    body_file_html "$project_temp_file"

    #componente header
    compile_header_project "$project_temp_file"

    #open estrutura pagina do project
    open_info_and_body_cards_page "$project_temp_file"

    #informacoes do projeto
    create_line_info_project

    #compilar informacoes do projeto
    compile_info_project 

    #compilar os packages existentes em cards
    compile_packages_cards

    #close estrutura pagina do project
    close_info_and_body_cards_page "$project_temp_file"
      
    #compilar o footer estatico da pagina do projeto
    compile_footer_project

    #finalizar o html
    end_file_html "$project_temp_file"

    #construir o index do projeto
    if [ ! -d "../../../public/help/$project_name" ] ; then
      mkdir "../../../public/help/$project_name"
    fi
    project_index_file="../../../public/help/$project_name/index.html"
    if [ -e "$project_index_file" ] ; then
      mv "$project_index_file" "../../logs/backups/backup_$project_name_no_space-$date.html"
    fi
    cp "$project_temp_file" "$project_index_file"    
  fi
  
}

function build_project_links_page(){
  if [ "$generate_links_page" == "true" ] && [ $compile_package_errors -eq 0 ] ; then
    
    project_html_links_file="../../../public/help/$project_name/links.html"

    if [ ! -e "$project_html_links_file" ] ; then
      touch "$project_html_links_file"
    fi

    ##### INICIO COMPONENTES #####
    begin_file_html "$project_html_links_file"

    #componente head
    compile_head_links_project "$project_html_links_file"

    #body da pagina
    body_file_html "$project_html_links_file"

    #componente header
    compile_header_project "$project_html_links_file"

    #open estrutura pagina do project
    open_info_and_body_cards_page "$project_html_links_file"
         
    search_dir='packages'
    for package_path_link in "$search_dir"/*
    do
      if [ -e "$package_path_link/links.txt" ] ; then
        #Iniciar criacao tabela de componentes
        copy_project_component table_links "$project_html_links_file"

        while IFS= read -r link_line || [[ -n "$link_line" ]]; do
          #remover espacos inicio e fim
          link_line=$(echo "$link_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
          comentario=$(echo "$link_line" | grep -v ^"#")
          component_link_type=""
          if [ -n "$comentario" ] ; then
            component_type=$(echo $link_line | cut -d";" -f 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            case "$component_type" in
              "p")
                component_link_type="Package"
                component_package_name=$(echo $link_line | cut -d";" -f 2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
              ;;
              "s")
                component_link_type="$section_translate"
              ;;
              "ss")
                component_link_type="$subsection_translate"
              ;;
            esac
            component_link_name=$(echo $link_line | cut -d";" -f 2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            component_direct_link=$(echo $link_line | cut -d";" -f 3 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            component_laravel_link=$(echo $link_line | cut -d";" -f 4 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            copy_project_component table_line_links "$project_html_links_file"
            $(sed -i "s|{{package_name}}|$component_package_name|g" $project_html_links_file ) 
            $(sed -i "s|{{component_link_type}}|$component_link_type|g" $project_html_links_file )
            $(sed -i "s|{{component_link_name}}|$component_link_name|g" $project_html_links_file )
            $(sed -i "s|{{component_direct_link}}|$component_direct_link|g" $project_html_links_file )
            $(sed -i "s|{{component_laravel_link}}|$component_laravel_link|g" $project_html_links_file )            
          fi          
        done < "$package_path_link/links.txt"
        echo "</table>" >> "$project_html_links_file"
      fi
    done   
    echo -e '</div>\n</div>\n</div>\n</div>' >> "$project_html_links_file"
    end_file_html "$project_html_links_file"
  fi
}

function compile_all_packages(){
  search_dir='packages'
  for package_path in "$search_dir"/*
  do
    package_dir_name="$package_path"
    echo ""
    print_message "" "compiler: $msg_try_compile_package $package_path"
    msg_log_before_check_var="$msg_log_before_check_var\n[$(date +"%d-%m-%Y %T")] $header compiler: $msg_try_compile_package $package_path"
    build_package_file_html
  done
}

function compile_passed_packages(){  
  packages_line="$1"
  pkgs_delete_space=$(echo "$1" | sed 's/ /-/g' | sed 's/ /-/g')

  number_char=$(expr length "$pkgs_delete_space" - length `echo "$pkgs_delete_space" | sed "s/,//g"`)

  packages=$((number_char+1))

  for((p=1; p<=$packages; p++))
  {
    package_dir_name=$(echo "$packages_line" | cut -d, -f $p)
    package_dir_name="packages/$package_dir_name"

    echo ""
    print_message "" "compiler: $msg_try_compile_package $package_dir_name"
    
    if [ -d "$package_dir_name" ] ; then     
      build_package_file_html
    else
      print_message $error "$package_not_found $package_dir_name"
      msg_log_before_check_var="$msg_log_before_check_var\n\n[$(date +"%d-%m-%Y %T")] $header $package_not_found $package_dir_name" 
      compile_package_errors=$((compile_package_errors+1))
    fi
  }
}

function clear_backup_files(){  
  if [ -n "$(ls -A ../../logs/backups)" ]; then
    print_message $warning "$remove_all_backup_files"
    gio trash ../../logs/backups/*
    print_message $ok "$backup_files_deleted_successfully"
  else
    print_message "$warning" "$empty_directory_backups"
  fi  
}

##### EXECUCAO DO SCRIPT
checkLanguage #check arquivo de linguagem
if [ "$1" == "--clear-backups" ] || [ "$1" = "-cbk" ] ; then
  clear_backup_files
elif [ "$1" == "-cp" ] || [ "$1" == "--compile-project" ] ; then
  check_before_compiler
  create_temp_files
  build_project_file_html
  #limpar arquivos temporarios que nao irao ser mais utilizados
  rm -f ../../logs/tmp/*
  exit_with_success
else
  check_before_compiler #checagens necessarias antes de compilar
  check_test_option "$1" "$2" #check if exist test option
  if [ -z "$1" ] || [ "$1" == "-t" ] || [ "$1" == "--test" ] && [ -z "$2" ] ; then
    compile_all_packages
  elif [ "$1" == '-t' ] ; then
    compile_passed_packages "$2"
  else
    compile_passed_packages "$1"
  fi
  build_project_links_page
  build_project_file_html
  #limpar arquivos temporarios que nao irao ser mais utilizados
  rm -f ../../logs/tmp/*
  if [ $compile_package_errors -gt 0 ] ; then
    exit_with_error
  else
    exit_with_success
  fi
fi
