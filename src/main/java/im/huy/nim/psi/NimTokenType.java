package im.huy.nim.psi;

import com.intellij.psi.tree.IElementType;
import im.huy.nim.NimLanguage;
import org.jetbrains.annotations.NonNls;
import org.jetbrains.annotations.NotNull;

/**
 * Created by rgv151 on 6/16/15.
 */
public class NimTokenType extends IElementType {

    public NimTokenType(@NotNull @NonNls String debugName) {
        super(debugName, NimLanguage.INSTANCE);
    }

    @Override
    public String toString() {
        return super.toString();
    }
}
