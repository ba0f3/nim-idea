package im.huy.nim;

import com.intellij.openapi.fileTypes.LanguageFileType;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;

/**
 * Created by huy on 6/15/15.
 */
public class NimFileType extends LanguageFileType {
    public static final NimFileType INSTANCE = new NimFileType();

    private NimFileType() {
        super(NimLanguage.INSTANCE);
    }


    @NotNull
    @Override
    public String getName() {
        return "Nim Source";
    }

    @NotNull
    @Override
    public String getDescription() {
        return "Nim language source code";
    }

    @NotNull
    @Override
    public String getDefaultExtension() {
        return "nim";
    }

    @Nullable
    @Override
    public Icon getIcon() {
        return NimIcons.ICON_NIM_16;
    }
}
