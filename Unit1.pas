unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TObjEstudo = class
  private
    FDescription   : string;
  public
    property Description : string read FDescription write FDescription;
  end;

  EMathError = class(Exception);
  EDivByZero = class(EMathError);

  TformEstudo = class(TForm)
    btnObjCreate: TButton;
    txtObjName: TEdit;
    lblObjInMemory: TLabel;
    lbxObjCreated: TListBox;
    btnObjRemove: TButton;
    Button2: TButton;
    procedure btnObjCreateClick(Sender: TObject);
    procedure lbxObjCreatedClick(Sender: TObject);
    procedure btnObjRemoveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formEstudo: TformEstudo;
  objectList : TList;

const
  NUM_OBJ_IN_MEMORY_MSG     : string  = 'N�mero de objetos na mem�ria: ';

  OBJ_IN_MEMORY_WARN        : string  = 'O objeto ainda est� na mem�ria!' +
                                        #13#10 +
                                        #13#10 +
                                        'Use "FreeAndNil" para liberar totalmente o objeto da mem�ria.';

  ERROR_FIND_OBJ_IN_LISTBOX : string =  'Erro ao selecionar um objeto na lista!';

  ACCESS_VIOLATION_WARN     : string =  'Tentar manipular um objeto n�o instanciado ' +
                                        'resultar� em Access Violation!';

implementation

{$R *.dfm}

procedure TformEstudo.btnObjCreateClick(Sender: TObject);
var
  obj : TObjEstudo;
begin
  if txtObjName.Text = '' then
  begin
    ShowMessage('D� um nome para o objeto!');
    exit;
  end;

  {Instancia o objeto}
  obj := TObjEstudo.Create;

  obj.Description := txtObjName.Text;

  {Adiciona o objeto � lista de objetos}
  objectList.Add(obj);

  {Adiciona os dados do objeto criado � listBox}
  lbxObjCreated.AddItem(obj.Description, obj);

  txtObjName.Clear;

  txtObjName.SetFocus;

  lblObjInMemory.Caption := NUM_OBJ_IN_MEMORY_MSG + IntToStr(objectList.Count);
end;

procedure TformEstudo.btnObjRemoveClick(Sender: TObject);
var
  i, indexItemToDelete : Integer;
  obj : TObjEstudo;
begin
  {Percorre a listBox para encontrar o item selecionado}
  for i := 0 to lbxObjCreated.Count - 1 do
  begin
    {Caso encontre o item selecionado...}
    if lbxObjCreated.Selected[i] then
    begin
      {Manda o item da listBox para o objeto. N�o foi necess�rio criar o objeto
      novamente, pois ele j� estava em mem�ria, com isso esta vari�vel s� recebe
      a refer�ncia ao objeto que j� foi instanciado}
      obj := objectList.Items[i];
      {Guarda o �ndice do objeto a ser deletado da lista}
      indexItemToDelete := i;
      {Caso encontre o objeto selecionado, interrompe o la�o. Apenas por motivos
      de performance}
      Break;
    end;
  end;

  {Remove o objeto da lista de objetos}
  objectList.Remove(obj);

  {Remove a descri��o do objeto da listBox de objetos}
  lbxObjCreated.Items.Delete(indexItemToDelete);

  try
    FreeAndNil(obj);
  except on E : Exception do
    ShowMessage(ACCESS_VIOLATION_WARN);
  end;

  lblObjInMemory.Caption := NUM_OBJ_IN_MEMORY_MSG + IntToStr(objectList.Count);

  if Assigned(obj) then
    ShowMessage(OBJ_IN_MEMORY_WARN);
end;

procedure TformEstudo.Button2Click(Sender: TObject);
var
  i : Integer;
  obj : TObjEstudo;
begin
  {Limpa a listBox}
  for i := (objectList.Count - 1) downto 0 do
  begin
    obj := objectList.Items[i];
    objectList.Remove(obj);
    lbxObjCreated.Items.Delete(i);
  end;

  lblObjInMemory.Caption := NUM_OBJ_IN_MEMORY_MSG + IntToStr(objectList.Count);

  try
    FreeAndNil(obj);
  except on E : Exception do
    ShowMessage(ACCESS_VIOLATION_WARN);
  end;
end;

procedure TformEstudo.FormCreate(Sender: TObject);
begin
  objectList := TList.Create;
end;

procedure TformEstudo.lbxObjCreatedClick(Sender: TObject);
var
  i : Integer;
  obj : TObjEstudo;
begin
  try
    for i := 0 to lbxObjCreated.Count - 1 do
    begin
      if lbxObjCreated.Selected[i] then
        obj := objectList.Items[i];
    end;

    txtObjName.Text := obj.Description;
  except on E : Exception do
    Exit;
  end;
end;

end.
