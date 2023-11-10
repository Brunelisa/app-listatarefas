import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllertarefa = TextEditingController();

  Future<File> _getFile() async{ //retornando o local do arquivo
    final diretorio = await getApplicationDocumentsDirectory(); //descobre o caminho que salva os arquivos no celular
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa(){
    String textoDigitado = _controllertarefa.text;

    //criando dados da lista
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa); //adicionando a tarefa na lista
    });


    _salvarArquivo(); //salvando o arquivo no celular
    _controllertarefa.text = "";

  }


  _salvarArquivo() async{

    var arquivo = await _getFile();


    String dados = json.encode(_listaTarefas); //convertendo para json
    arquivo.writeAsString(dados);

    //print("Caminho: " + diretorio.path);

  }

  _lerArquivo() async{
    try{
      final arquivo = await _getFile();
      return arquivo.readAsString(); //recuperando o arquivo
    }catch(e){
      print(e.toString());
      return null; //se der erro retorna nulo
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _lerArquivo().then((dados){ //then = após concluir a execução do ler arquivo, ele irá executar o setstate
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  //criando o widget lista através de um método
  Widget criarItemLista(context, index){

    final item = _listaTarefas[index]["titulo"];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()), //gera sempre um valor diferente
        direction: DismissDirection.endToStart,
        onDismissed: (direction){
          //recuperar ultimo item excluido
          _ultimaTarefaRemovida = _listaTarefas[index];

          //remove item
          _listaTarefas.removeAt(index);
          _salvarArquivo();
          //snackbar
          final snackbar = SnackBar(
            //backgroundColor: Colors.green,
            duration: Duration(seconds: 5), //duração que a snackbar fica visivel
              content: Text("Tarefa removida"),
            //desfazendo ação de remover
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){
                  setState(() {
                    _listaTarefas.insert(index, _ultimaTarefaRemovida);
                  });

                    _salvarArquivo();
                }
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar); //exibindo snackbar no app


        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                  Icons.delete,
                color: Colors.white,

              )
            ],
          ),
        ),

        child: CheckboxListTile(
            title: Text(_listaTarefas[index]["titulo"]),
            value: _listaTarefas[index]["realizada"],
            onChanged: (valorAlterado){
              //atualizando o checkbox (se está marcado ou nao)
              setState(() {
                _listaTarefas[index]["realizada"] = valorAlterado;
              });

              _salvarArquivo();
              // print("Valor: " + valorAlterado.toString());
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    //_salvarArquivo();
    //print("itens" + DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text("Lista de tarefas"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                  itemCount: _listaTarefas.length,
                itemBuilder: criarItemLista
            )
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: (){
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Adicionar tarefa"),
                  content: TextField(
                    controller: _controllertarefa, //acessando o que foi digitado
                    decoration: InputDecoration(
                      labelText: "Digite a tarefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancelar"),
                        
                    ),
                    TextButton(
                      onPressed: (){
                        //salvar
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                      child: Text("Salvar"),

                    )
                  ],
                );
              }
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }



}
