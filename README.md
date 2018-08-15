# t.bidna

package Programmieraufgabe;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.JTree;
import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeSelectionModel;

import org.junit.runner.JUnitCore;
import org.junit.runner.*;
import org.junit.runner.notification.Failure;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

import XML_10.SimpleFrameworkDeAndSerializer;
import baum_08.FlexibleTreeNode;
import baum_08.MyGTree;
import baum_08.MyGuifiableObject;
import baum_08.TreeExpansionUtil;
import turban.utils.ErrorHandler;
import turban.utils.IGuifiable;
import turban.utils.ReflectionUtils;
import turban.utils.UserMsgException;

/**
 * Classe JTreeTestFaelle kontrolliert das Verhalten vom JFrame und enthaelt alle fuer das JFenster noetigen Variablen und die Methoden ,
 * die Buttons Funktionen beschreiben 
 */
 
public class JTreeTestFaelle<T extends IGuifiable> extends JFrame {
	private DefaultTreeModel _myTreeModel;
	private JTree _jtree;
	private FlexibleTreeNode <MyGuifiableObject> _tnRoot=null; 
	TestsClass tc = new TestsClass();
	List<String> listMethod = new ArrayList<>();
	List<String> listIgnore = new ArrayList<>();

	private JPanel panelBaum;
	private JPanel panelMeldung;
	private JPanel panelKnopf;
	private JScrollPane treeViewScrollBaum;
	private JScrollPane treeViewScrollMeld;
	private JButton btnStart;
	private JButton btnStop;
	private JButton btnXML;
	private JTextArea textMeld;
	private JLabel runOrStop; 
	private JFileChooser chooser;
	private Result result;
	private Thread thrStart ;

	private boolean btnOn = false;

	private FlexibleTreeNode <MyGuifiableObject> tnSelected;


	public JTreeTestFaelle () {
		try {

			_jtree = new JTree (_myTreeModel);
			_jtree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);

			treeViewScrollBaum = new JScrollPane(_jtree);
			treeViewScrollBaum.setPreferredSize(new Dimension(450,250));

			textMeld = new JTextArea();
			treeViewScrollMeld = new JScrollPane(textMeld);
			treeViewScrollMeld.setPreferredSize(new Dimension(450,250));

			panelBaum = new JPanel();
			this.add(panelBaum,BorderLayout.WEST);
			panelBaum.add(treeViewScrollBaum);

			panelMeldung = new JPanel();
			this.add(panelMeldung,BorderLayout.EAST);
			panelBaum.add(treeViewScrollMeld);

			panelKnopf= new JPanel();
			this.add(panelKnopf,BorderLayout.SOUTH);
			runOrStop = new JLabel("stop");

			baumAusDerListeBekommen();
			btnStart();
			btnStop();
			treeSelectionListner();
			btnXML();

			panelKnopf.add(btnStart);
			panelKnopf.add(btnStop);
			panelKnopf.add(runOrStop);
			panelKnopf.add(btnXML);

			_jtree.setRootVisible(false);	

			this.pack();
			this.setSize(940, 400);
			this.setVisible(true);
			this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		}
		catch (Throwable ex) {
			ErrorHandler.logException(ex, true, SimpleFrameworkDeAndSerializer.class, "Fehler im Konstruktor()"+ex.getMessage());
		}
	}

	/**
	 * baumAusDerListeBekommen() 
	 * Die Liste mit den Klassennamen und den @Test-Methoden der Klassen wandeln wir in den FlexibleTreeNode<MyGuifiableObject> um
	 * @param _tnRoot Hauptknoten des Baums
	 * @param _myTreeModel damit der Baum eine Ierarhieform hat
	 * @param _jtree selbst der Baum
	 * @param treeOffenHalten() haelt die Knoten offen 
	 * 
	 * NOTE: The function Errorhandler#logException will ignore this exception and not perform a logging.
	 */
   
	public void baumAusDerListeBekommen() {

		try {
			_tnRoot = new FlexibleTreeNode <MyGuifiableObject>(new MyGuifiableObject ("Root"));
			_myTreeModel = new DefaultTreeModel(_tnRoot);
			_jtree.setModel(_myTreeModel);

			FlexibleTreeNode<MyGuifiableObject> tnParent;
			for(Class c: tc.getTestSetClasses()) {
				tnParent = new FlexibleTreeNode<>(new MyGuifiableObject (c.getName()+"#"));

				listMethod = ReflectionUtils.getMethodNamesWithAnnotation(c,org.junit.Test.class);
				FlexibleTreeNode<MyGuifiableObject> tnChild;


				for(String sMeth:listMethod) {
					if(ignorKontrolle(c,sMeth)) 
						tnChild= new FlexibleTreeNode<>(new MyGuifiableObject (sMeth +" -I"));
					else 
						tnChild= new FlexibleTreeNode<>(new MyGuifiableObject (sMeth +"."));
					tnParent.add(tnChild);
				}
				_tnRoot.add(tnParent);
			}
			treeOffenHalten();
		}
		catch (Throwable ex) {
			ErrorHandler.logException(ex, true, SimpleFrameworkDeAndSerializer.class, "Fehler in baumAusDerListeBekommen()"+ex.getMessage());
		}

	}

	/**
	 * ignorKontrolle(Class c, String sMeth): Class, die Methode sMeth enthaelt
	 * Die Liste mit den @Test@-Methoden nach @Ignore ueberprueft
	 * return bln = true -> Ignore ist da, ...=false -> nicht
	 * NOTE: The function Errorhandler#logException will ignore this exception and not perform a logging.
	 */
   
	public boolean ignorKontrolle(Class c, String sMeth) {
		boolean bln = false;
		listIgnore = ReflectionUtils.getMethodNamesWithAnnotation(c,org.junit.Ignore.class);

		if(listIgnore.size()!=0) 
			for(String sIgn : listIgnore) 
				bln = (sMeth.equals(sIgn)) ? true : false; 

		return bln;	
	}

	
	/**
	 * btnStart(): kontrolliert den Button Start
	 * Die Liste mit den @Test@-Methoden nach @Ignore ueberprueft
	 * @param thrStart steht fuer Thread. Er startet sobald der Button aktiev ist, nachdem btnOn gechecket wird
	 * Fallst die @Test-Methode falsch gelaufen ist, bekommt der Name "-F"
	 * 							falls alles gut gelaufen ist, dann "-R"
	 * NOTE: The function Errorhandler#logException will ignore this exception and not perform a logging.
	 */
   
	public void btnStart() {
		try {
			btnStart = new JButton ("Start");
			btnStart.addActionListener((ActionEvent e)-> {
				btnOn = true;

				thrStart = new Thread (new Runnable() {
					@Override
					public void run() {
						try {
							int i=0;
							for(Class c : tc.getTestSetClasses()) {

								if (btnOn==true) {
									result = JUnitCore.runClasses(c);
									FlexibleTreeNode <MyGuifiableObject> parent = (FlexibleTreeNode<MyGuifiableObject>) _tnRoot.getChildAt(i);
									MyGuifiableObject userObjectParent = parent.getUserObject();
									runOrStop.setText("running");

									if(result.getFailureCount()!=0) {
										for(FlexibleTreeNode<MyGuifiableObject> node : parent.getChildren()) 
										{
											String stCh ="";
											for (Failure failure : result.getFailures()) 
											{
												if(node.getUserObject().toGuiString().equals(failure.getDescription().getMethodName()+".")) {
													stCh= node.getUserObject().toGuiString().replace(".", "-F");
													userObjectParent.setGuiString(userObjectParent.toGuiString().replace("#"," -F"));
												}
												else 
													stCh = node.getUserObject().toGuiString().replace(".", " -R");
												node.getUserObject().setGuiString(stCh);

											}
										}
									}
									else {
										userObjectParent.setGuiString(userObjectParent.toGuiString().replace("#"," -R"));
										for(FlexibleTreeNode<MyGuifiableObject> node : parent.getChildren()) {
											String stCh = node.getUserObject().toGuiString().replace(".", " -R");
											node.getUserObject().setGuiString(stCh);
										}
									}
									Thread.sleep(1000);
									treeOffenHalten();
								}
								i++;
							}
						}
						catch (Exception ex) {
							ErrorHandler.logException(ex, false, JTreeTestFaelle.class, "Error in Thread " + ex.getMessage() );
						}
					}
				});
				thrStart.start();
			});
		}
		catch (Throwable ex) {
			ErrorHandler.logException(ex, true, JTreeTestFaelle.class, "Fehler in btnStart()"+ex.getMessage());
		}

	}

	public void treeOffenHalten() {
		List<Integer> lstIntsExpStates=TreeExpansionUtil.getExpansionState( _jtree);
		_myTreeModel.reload();
		TreeExpansionUtil.setExpansionState( _jtree,lstIntsExpStates);		
	}
	
	/**
	 * btnStop():  Button Stop
	 * setzt btnOn auf false
	 * NOTE: The function Errorhandler#logException will ignore this exception and not perform a logging.
	 */
   
	public void btnStop(){
		try {
			btnStop = new JButton ("Stop");
			btnStop.addActionListener((ActionEvent e) -> {
				btnOn = false;
				runOrStop.setText("stopped...");
			});
		}
		catch (Throwable ex) {
			ErrorHandler.logException(ex, true, JTreeTestFaelle.class, "Fehler in btnStop()"+ex.getMessage());
		}
	}
	
	/**
	 * treeSelectionListner()  
	 * wenn ein Knoten (@Test-Methode) im Baum ausgewaehlt ist , wird eine Nachricht uebertragen
	 * NOTE: The function Errorhandler#logException will ignore this exception and not perform a logging.
	 */
   
	public void treeSelectionListner() {
		try {
			_jtree.addTreeSelectionListener(new TreeSelectionListener() {
				@SuppressWarnings("unchecked")
				public void valueChanged(TreeSelectionEvent e) {
					try {
						tnSelected = (FlexibleTreeNode  <MyGuifiableObject>) _jtree.getLastSelectedPathComponent();
                         if (tnSelected== null) {return;}
						
						for(Class a:tc.getTestSetClasses()) {
							result=org.junit.runner.JUnitCore.runClasses(a);
							if( result.getFailureCount()!=0) {
								for(Failure fail:result.getFailures()) 
									if(tnSelected.getUserObject().toGuiString().equals(fail.getDescription().getMethodName()+"-F")) {
										textMeld.setText("	"+fail.toString()+"	");
										return;
									}
							}
							if(tnSelected.getUserObject().toGuiString().contains(" -I")) {
								textMeld.setText("???");
							}
							else{
								textMeld.setText("Der Test ist guuuuuuuuuuuuut gelaufen");
							}
						}
					}
					catch (Throwable ex) {
						ErrorHandler.logException(ex, true, JTreeTestFaelle.class, "Fehler in valueChanged() von SelectionOption"+ex.getMessage());
					}
				}
			});
		}
		catch (Throwable ex) {
			ErrorHandler.logException(ex, true, JTreeTestFaelle.class, "Fehler in treeSelectionListner()"+ex.getMessage());
		}
	}
  
	/**
	 *btnXML()
	 * speichert alle Methodennachrichten in einer Datei
	 * @param result eine Liste mit allen Fehlermeldungen
	 * NOTE: The function Errorhandler#logException will ignore this exception and not perform a logging.
	 */
   
	public void btnXML() {
		try {
			btnXML = new JButton("to XML");
			btnXML.addActionListener((ActionEvent e)-> {
				XML xml = new XML();
				Test test =null;
				String strErg = "";

				for(Class a:tc.getTestSetClasses()) {
					listMethod = ReflectionUtils.getMethodNamesWithAnnotation(a,org.junit.Test.class);

					result=org.junit.runner.JUnitCore.runClasses(a);
					for(String sMeth:listMethod) {
						if( result.getFailureCount()!=0) 
							for(Failure fail:result.getFailures()) 
								if(sMeth.equals(fail.getDescription().getMethodName())) 
									strErg = ("Test durchgefallen	"+fail.toString());

								else if(ignorKontrolle(a,sMeth)) 
									strErg = "Test ignoriert";

								else
									strErg = "Test bestanden";

						else 
							strErg = "Test bestanden";

						test =new Test (a.toGenericString(),sMeth,strErg); 
						xml._lstTests.add(test);
					}
				}
				chooser(xml);

			});
		}catch (Throwable ex) {
			ErrorHandler.logException(ex, true, JTreeTestFaelle.class, "Fehler in btnXML()"+ex.getMessage());
		}
	}

	public void chooser(XML xml) {
		chooser = new JFileChooser();
		int pfad = chooser.showSaveDialog(this);
		if (pfad == JFileChooser.APPROVE_OPTION) {
			File file = chooser.getSelectedFile();
			try {
				SimpleFrameworkDeAndSerializer.serializeToFile(xml, file.getAbsolutePath());
			} catch (Throwable ex) {
				ErrorHandler.logException(ex, true, JTreeTestFaelle.class, "Fehler in chooser"+ex.getMessage());					}

		} else {

		}
	}
	public static void main(String[] args) {
		try {
			JTreeTestFaelle tree = new JTreeTestFaelle ();
		}
		catch (Throwable ex) {
			ErrorHandler.logException(ex, true, MyGTree.class, "Fehler in main()");
		}

	}

}
