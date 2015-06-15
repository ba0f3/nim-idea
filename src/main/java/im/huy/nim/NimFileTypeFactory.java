package im.huy.nim;

import com.intellij.openapi.fileTypes.FileTypeConsumer;
import com.intellij.openapi.fileTypes.FileTypeFactory;

/**
 * Created by huy on 6/15/15.
 */
public class NimFileTypeFactory extends FileTypeFactory {

    @Override
    public void createFileTypes(FileTypeConsumer fileTypeConsumer) {
        fileTypeConsumer.consume(NimFileType.INSTANCE, "nim");
    }
}
