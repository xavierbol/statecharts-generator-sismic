package be.ac.umons.bol.generator.sismic.specification;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import be.ac.umons.bol.generator.sismic.Utils;

public class Specification {
    private String event = "";
    private String guard = "";
    private ArrayList<String> listActions;
    
    public Specification(String specification) {
        if (!specification.isEmpty()) {
            listActions = new ArrayList<String>();
            extractSpecifications(specification);
        }
    }
    
    public Specification(String specification, String actions) {
    	if (!specification.isEmpty()) {
    		extractSpecifications(specification);
    	}
    	
    	if (!actions.isEmpty()) {
    		listActions = new ArrayList<String>();
    		treatActions(actions);
    	}
    }
    
    public Specification(String event, String guard, ArrayList<String> actions) {
        this.event = event;
        this.guard = guard;
        this.listActions = new ArrayList<>(actions.size());

        this.listActions.addAll(actions);
    }

    public String getEvent() {
        return event;
    }

    public void setEvent(String event) {
        this.event = event;
    }

    public String getGuard() {
        return guard;
    }

    public void setGuard(String guard) {
        this.guard = guard;
    }

    public ArrayList<String> getListActions() {
        return listActions;
    }
    
    public boolean haveSameTrigger(Specification specification) {
        if (specification == null) {
            return false;
        }
        
        return event.equals(specification.getEvent()) && guard.equals(specification.getGuard());
    }
    
    public void addAction(String action) {
        if (listActions == null) {
            listActions = new ArrayList<String>();
        }
        
        treatActions(action);
    }

    private void extractSpecifications(String specification) {
        String txt = specification.replaceAll("\\n", " ");
        Utils.searchBinaryOperator(txt);

        int indexG = txt.indexOf("["); // check if it exists guards
        int indexA = txt.indexOf("/"); // check if it exists actions

        if (indexA != -1) { // if there is an action
            String[] transitionWithAction = txt.split("/");
            treatActions(transitionWithAction[1]);
            txt = transitionWithAction[0].trim();
        }

        if (indexA != 0) { // if the index isn't the first character in the string
            // then it exists either event or event or both 
            if (indexG != -1) { // if there is a guard
                int firstIndex = txt.indexOf("[");
                int endIndex = txt.indexOf("]", firstIndex);
                char[] charGuards = new char[endIndex - (firstIndex + 1)];

                txt.getChars(firstIndex +  1, endIndex, charGuards, 0);
                guard = String.valueOf(charGuards);
                treatGuard();

                if (indexG != 0) { // check if it exists events
                    char[] charEvent = new char[firstIndex];

                    txt.getChars(0, firstIndex, charEvent, 0);

                    event = String.valueOf(charEvent).trim();
                }
            } else {
                event = txt;
            }
            treatEvent();
        }
    }

    private void treatActions(String action) {
        action = action.replaceAll("\\btrue\\b", "True"); // replace true by True
        action = action.replaceAll("\\bfalse\\b", "False"); // replace false by False
        action = action.replaceAll("raise\\s*(\\w+\\.*\\w*);?", "send(\"$1\")");
        action = action.replaceAll("\\bvalueof\\s*\\((\\w+)\\)\\s*", "event.$1");
        
        if (action.contains(";")) {
            String[] tabActions = action.split(";");

            for (String a : tabActions) {
                listActions.add(a.trim());
            }
        } else {
            listActions.add(action.trim());
        }
    }

    private void treatGuard() {
        guard = guard.replaceAll("(\\s)&&(\\s)", "$1and$2"); // replace && by and
        guard = guard.replaceAll("(\\s)\\|\\|(\\s)", "$1or$2"); // replace || by or
        guard = guard.replaceAll("\\btrue\\b", "True"); // replace true by True
        guard = guard.replaceAll("\\bfalse\\b", "False"); // replace true by False
        guard = guard.replaceAll("!([^=])", "not $1"); // replace negation ! by not
        guard = guard.replaceAll("(active\\()(.*\\.(.*))(\\))", "$1'$3'$4"); // replace for example active(Car.On.r1.Driving) by active('Driving')
    }

    private void treatEvent() {
        String regex = "after (\\d+)\\s*(ms|s|m|h)";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(event);

        if (m.find()) { // if it's a temporal event with keyword after... then it must to change into after(...)
            String eventTime = m.group(0);
            float value = Float.valueOf(m.group(1));
            String timeUnit = m.group(2);

            switch (timeUnit) {
                case "ms":
                    value /= 1e3;
                    break;
                case "us":
                    value /= 1e6;
                    break;
                case "ns":
                    value /= 1e9;
                    break;
            }

            event = event.replaceAll(eventTime, "").trim();
            String newGuard = "after(" + String.valueOf(value) + ")";
            if (guard.length() == 0) {
                guard = newGuard;
            } else {
                guard = guard.concat(" and " + newGuard);
            }
        }
        event = event.replaceAll("\\.", "_");
        event = event.replaceAll("\\b(always)\\b", ""); // always can be replaced by an auto transition
    }

    public String actionsToString() {
        StringBuilder res = new StringBuilder("actions :\n");

        for (int i = 0; i < listActions.size(); i++) {
            res.append(listActions.get(i));

            if (i < listActions.size() - 1) {
                res.append("\n");
            }
        }

        return res.toString();
    }
    
    @Override
    public boolean equals(Object o) {
        if (o instanceof Specification) {
            Specification temp = (Specification) o;

            if (event.equals(temp.getEvent()) && guard.equals(temp.getGuard()) && listActions.size() == temp.listActions.size()) {
                for (int i = 0; i < listActions.size(); i++) {
                    if (!listActions.get(i).equals(temp.listActions.get(i))) {
                        return false;
                    }
                }
                return true;
            }
        }

        return false;
    }

    @Override
    public String toString() {
        return "event :" + event + "\n" +
                "guard : " + guard +
                actionsToString();
    }
}
