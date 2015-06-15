package im.huy.nim.actions;

import com.intellij.ide.actions.CreateFileAction;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.ui.Messages;
import com.intellij.psi.PsiDirectory;
import com.intellij.psi.PsiElement;
import im.huy.nim.NimIcons;
import org.jetbrains.annotations.NotNull;

/**
 * Created by huy on 6/15/15.
 */
public class NewNimFileAction extends CreateFileAction {
    public NewNimFileAction() {
        super("Nim File",
        "Nim language source code",
        NimIcons.ICON_NIM_16);
    }

    @NotNull
    @Override
    protected PsiElement[] invokeDialog(Project project, PsiDirectory directory) {
        MyValidator validator = new MyValidator(project, directory);
        Messages.showInputDialog(
                project,
                "Enter a new Nim file name",
                "New Nim File",
                NimIcons.ICON_NIM_32,
                null,
                validator
        );
        return validator.getCreatedElements();
    }

    @NotNull
    @Override
    protected PsiElement[] create(String newName, PsiDirectory directory) throws Exception {
        return super.create(completeFileName(newName), directory);
    }

    private String completeFileName(String name) {
        return name.endsWith(".nim") ? name : name + ".nim";
    }

}
