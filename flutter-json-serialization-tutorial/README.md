# All about Json serialization

**Doc atualizado no notion: https://www.notion.so/fhsbatista/All-about-Json-serialization-318d8714f075407a90f0e95e40ae2c52**

## Dataclasses

Dataclasses são usadas para transportar amontoados de informações (como email e senha de usuário) entre banco de dados e camada de apresentação por exemplo.

Para esse tipo de classe, existem 3 funções que são úteis

- == → Para que a gente possa comparar objetos usando seus dados em vez de sua referência em memória.
- copyWith → Para clonar esses objetos
- toString → ainda não sei para o quê isso pode ser útil.

Implementar esses 3 métodos manualmente para todas as classes que se comportam como "dataclasses" tomariam muito tempo e gerariam muito boilerplate gerando bastante espaço para erros manuais.

Como evitar isso?

Bom, por enquanto, o dart não oferece uma solução "nativa". Temos bons packages da comunidade que resolvem isso entretando. Um desses packages é o `freezed`.

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled.png)

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%201.png)

## Json serialization

Bom, entendemos o que são dataclasses. Mas quando chegar a hora de se comunicar com bancos de dados, não iremos conseguir colocar no banco uma dataclass e nem receber uma dataclass pois o banco de dados não vai salvar dados de tipos não primitivos. Para isso, precisamos fazer conversões da dataclass para json e poder converter um json em um data class. Para isso, normalmente temos um método para cada, com nomes normalmente como `toJson` e `from Json.`

Assim como os métodos usados em uma dataclass, implementar manualmente esses métodos de conversão podem ser bem trabalhosos e propensos a erros já que uma dataclass pode normalmente conter vários campos. De novo, o dart não tem algo "nativo" para resolver isso, mas temos um outro package que ajuda nisso, que é o `json serializable`.

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%202.png)

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%203.png)

## Packages que serão usados

### Dev dependencies

`build_runner`

`freezed`

`json_serializable`

### Regular dependencies

`freezed_annotation`

`json_annotation`

## Estrutura de classes do projeto

Teremos duas classes principais:

- Settings: Vai ser responsável por guardar as configurações que o app deve observar para decidir como mostrar cores, funcionalidades e dados do usuário. Contém os campos: `User user`, `bool isPremium` e `List<Color> themeColors`.
- User: Classe responsável por guardar dados de um usuário. Contém: `String email` e `int phoneNumber`.

## Disclaimer sobre o uso de freezed no projeto

Esse projeto não visa entrar em muitos detalhes sobre o `freezed`. Ele está sendo usado meramente para facilitar a implementação de dataclasses, as quais posteriormente terão as conversões de json que é o foco do projeto. É somente nas coisas relacionadas a json que o projeto irá entrar em detalhes.

## Snippets para o projeto

Para facilitar a escrita, podemos configurar snippets no vscode. Para isso, cole o código abaixo no arquivo de snippets do dart (dart.json).

Obs: Para chegar em tal arquivo, abra a paleta de comandos, e busce por "snippets preferences" e depois busque por "dart".

```jsx
{
 	"Part statement": {
		"prefix": "pts",
		"body": [
			"part '${TM_FILENAME_BASE}.g.dart';",
		],
		"description": "Creates a filled-in part statement"
	},
	"Part 'Freezed' statement": {
		"prefix": "ptf",
		"body": [
			"part '${TM_FILENAME_BASE}.freezed.dart';",
		],
		"description": "Creates a filled-in freezed part statement"
	},
	"Freezed Data Class": {
		"prefix": "fdataclass",
		"body": [
			"@freezed",
			"class ${1:DataClass} with _$${1:DataClass} {",
			"  const ${1:DataClass}._();",
			"  const factory ${1:DataClass}(${2}) = _${1:DataClass};",
			"}"
		],
		"description": "Freezed Data Class"
	},
        "From JSON": {
		"prefix": "fromJson",
		"body": [
			"factory ${1}.fromJson(Map<String, dynamic> json) => _$${1}FromJson(json);"
		],
		"description": "From JSON"
	},
}
```

## fromJson

Para criar um `fromJson` para o dataclass:

- criar factory como o abaixo:

```dart
factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
```

- Informar o arquivo que deve ser gerado

```dart
part 'user.g.dart';
```

- Salvar o arquivo e rodar o build_runner para que o `.g` seja gerado.

Isso vai gerar um `fromJson` padrão. Porém, em alguns casos o padrão não vai ser o suficiente pois pode ser necessário que campos específicos sejam tratados de maneiras especiais (campos que podem ser nulos por exemplo). Para isso, podemos usar as anotações do `json_serializable`.

## E quando o nome do campo no json é diferente do nome do campo no nosso model?

Para esses casos, use a anotação `@JsonKey` no campo em questão e passe o parâmetro `name`.

ex:

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%204.png)

## Escondendo arquivos gerados

Arquivos gerados podem acabar poluindo bastante o explorer.

Se você está no vscode, use a extensão Explorer Exclude para esconder esses arquivos gerados.

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%205.png)

## Forçando a chamada do toJson nos métodos de conversão de json.

Quando um model tem um campo de um tipo não primitivo, você vai precisar que o método de conversão entenda isso e então chame o "toJson" do campo (em caso de conversão para json) para que a conversão funcione. Ex:

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%206.png)

Veja que `instance.user` é chamado diretamente. Mas teremos um problema. Precisamos que o `toJson` do user seja chamado.

Pra isso, podemos usar a anotação `@JsonSerializable` no factory da model, passando o argumento `explicitToJson` como `true`.

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%207.png)

Veja abaixo que agora o `toJson` é chamado para o `user`.

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%208.png)

Obs: Configurar essa anotação para todas as classes do projeto pode ser um pouco custoso. Para esse caso, é possível configurar essa e outras opções de forma global usando um `build.yml`. Crie esse arquivo na raíz do projeto e configure o que você precisar. (Nas docs do jsonserializable existem mais detalhes sobre esse yml eu acho).

Ex com todas as configurações possíveis. (Não irei usar todas)

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%209.png)

Minhas configurações finais serão essas:

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%2010.png)

## Dando suporte para tipos que não são suportados por padrão pelo JsonSerializable

Na classe `Settings`, precisamos de um `List<Color>`. `Color` no caso é do material, e não é um tipo suportado pelo JsonSerializable.

(é possível checar isso pelo documentação)

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%2011.png)

Então, colocando um campo que depende `Color` (como fiz na imagem abaixo), um erro vai acontecer na hora de rodar o `build_runner`

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%2012.png)

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%2013.png)

Para resolver esse caso, precisamos criar um converter para o tipo em questão. É bem simples, basta criar uma classe que implemente `JsonConverter` passando dois tipos. O primeiro tipo é o que deve extraído de um json e o segundo tipo é o que vai ser colocado em um json. Para o caso das cores, o primeiro tipo seria `Color` e o segundo poderia ser um `int` (por default a classe `Color` pode ser convertida para `int` e também ser gerada a partir de um `int`).

Ex:

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%2014.png)

Para usar esse converter, basta colocar uma anotação no campo que usa o tipo em questão, como abaixo:

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%2015.png)

Veja que agora o converter está sendo usado nos métodos de conversão:

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%2016.png)

## Resultados

Temos agora dois objetos. Um é um map que representa um json de `Settings` e o outro é um objeto `Settings` propriamente dito. O código abaixo irá printar o `toJson` (instância de `Settings` para um json) e o `fromJson` (instância do json para o `Settings`). Veja que no print do toJson, as regras que coloquei para campos específicos foram respeitadas:

- o Campo `phoneNumber` do `Settings` deve se chamar `number` no json.
- campos que são mais de uma palavra (como `themeColors` devem ficar no format "kebab" (ex: `fieldName` vai ser `field-name`).

![Untitled](All%20about%20Json%20serialization%20fe68205ac71a4baca66018f1061ed2a3/Untitled%2017.png)
