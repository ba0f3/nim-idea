package im.huy.nim.psi;

import com.intellij.psi.tree.IElementType;
import im.huy.nim.NimLanguage;
import org.jetbrains.annotations.NonNls;
import org.jetbrains.annotations.NotNull;

/**
 * Created by rgv151 on 6/16/15.
 */
public class NimElementType extends IElementType {
    public NimElementType(@NotNull @NonNls String debugName) {
        super(debugName, NimLanguage.INSTANCE);
    }
}
